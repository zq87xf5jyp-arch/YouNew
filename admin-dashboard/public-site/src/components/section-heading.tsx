export function SectionHeading({
  title,
  text,
  align = "left"
}: {
  title: string;
  text?: string;
  align?: "left" | "center";
}) {
  return (
    <div className={align === "center" ? "mx-auto max-w-3xl text-center" : "max-w-3xl"}>
      <h2 className="text-balance text-3xl font-black leading-tight text-white sm:text-4xl lg:text-5xl">{title}</h2>
      {text ? <p className="mt-4 text-pretty text-base leading-7 text-text-muted sm:text-lg">{text}</p> : null}
    </div>
  );
}
