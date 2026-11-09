import { scrypt, timingSafeEqual } from 'node:crypto';
import { compare, truncates } from 'bcryptjs';

const SCRYPT = /^scrypt32768\$[a-f0-9]{32}\$[a-f0-9]{128}$/;
// The preserved Supabase export contains cost-10 bcrypt records. Higher/unreviewed
// costs are rejected before work starts, so a corrupted record cannot exhaust CPU.
const LEGACY_BCRYPT = /^\$2[aby]\$10\$[./A-Za-z0-9]{53}$/;
// Deliberately non-account fixture: valid encoding, fixed cost, no usable identity.
const DUMMY_BCRYPT = '$2b$10$' + '.'.repeat(53);

export async function verifyPassword(
  password: string,
  stored: string | undefined,
  dummyScrypt: string,
): Promise<boolean> {
  if (!SCRYPT.test(dummyScrypt)) throw new Error('Invalid dummy credential configuration');
  const isScrypt = stored !== undefined && SCRYPT.test(stored);
  const isBcrypt = stored !== undefined && LEGACY_BCRYPT.test(stored);
  if (stored !== undefined && !isScrypt && !isBcrypt) throw new Error('Invalid credential record');
  if (password.length > 256) return false;

  // Every supported account and unknown email performs both bounded algorithms.
  // Do not cheaply skip the legacy work for unknown or modern accounts.
  const [, salt, digest] = (isScrypt ? stored! : dummyScrypt).split('$');
  const actual = await new Promise<Buffer>((resolve, reject) => {
    scrypt(password, salt, 64, { N: 32768, r: 8, p: 1, maxmem: 64 * 1024 * 1024 },
      (error, result) => error ? reject(error) : resolve(result));
  });
  const scryptMatches = timingSafeEqual(Buffer.from(digest, 'hex'), actual);
  const bcryptMatches = await compare(password, isBcrypt ? stored! : DUMMY_BCRYPT);
  // Never accept an ignored suffix beyond bcrypt's 72-byte input boundary.
  return isScrypt ? scryptMatches : isBcrypt && !truncates(password) && bcryptMatches;
}
