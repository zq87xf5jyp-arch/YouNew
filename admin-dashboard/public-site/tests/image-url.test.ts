import assert from "node:assert/strict";
import test from "node:test";

import { optimizedPublicImageUrl, responsivePublicImage } from "../src/lib/media/image-url.ts";

test("Supabase public object URLs become responsive render URLs", () => {
  const source = "https://project.supabase.co/storage/v1/object/public/content-images/articles/example/photo.webp";
  const result = optimizedPublicImageUrl(source, 960, 78);
  const parsed = new URL(result);
  assert.equal(parsed.pathname, "/storage/v1/render/image/public/content-images/articles/example/photo.webp");
  assert.equal(parsed.searchParams.get("width"), "960");
  assert.equal(parsed.searchParams.get("quality"), "78");
  assert.equal(parsed.searchParams.get("resize"), "contain");
});

test("responsive Supabase images receive a width-based srcset", () => {
  const source = "https://project.supabase.co/storage/v1/render/image/public/content-images/photo.webp?width=1920";
  const result = responsivePublicImage(source, [360, 720, 1200]);
  assert.match(result.src, /width=1200/);
  assert.match(result.srcSet ?? "", /width=360[^,]* 360w/);
  assert.match(result.srcSet ?? "", /width=1200[^,]* 1200w/);
});

test("Wikimedia TIFF assets are converted to browser-readable thumbnail URLs", () => {
  const source = "https://upload.wikimedia.org/wikipedia/commons/6/6f/example.tif";
  const result = optimizedPublicImageUrl(source, 800);
  assert.equal(result, "https://commons.wikimedia.org/wiki/Special:Redirect/file/example.tif?width=800");
});

test("unrecognized remote images stay untouched", () => {
  const source = "https://live.staticflickr.com/123/example_b.jpg";
  assert.deepEqual(responsivePublicImage(source, [360, 720]), { src: source, srcSet: undefined });
});
