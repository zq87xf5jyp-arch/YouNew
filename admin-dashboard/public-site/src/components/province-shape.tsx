import {
  netherlandsProvinceShapes,
  type NetherlandsProvinceShape,
  type ProvinceCoordinate
} from "@/lib/map/netherlands-provinces";

function pathForProvince(slug: string) {
  const shape: NetherlandsProvinceShape | undefined = netherlandsProvinceShapes.find((province) => province.name
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLocaleLowerCase("en")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "") === slug);
  if (!shape) return null;
  const points: ProvinceCoordinate[] = [];
  for (const polygon of shape.polygons) {
    for (const ring of polygon) points.push(...ring);
  }
  if (!points.length) return null;
  const longitudes = points.map(([longitude]) => longitude);
  const latitudes = points.map(([, latitude]) => latitude);
  const minLongitude = Math.min(...longitudes);
  const maxLongitude = Math.max(...longitudes);
  const minLatitude = Math.min(...latitudes);
  const maxLatitude = Math.max(...latitudes);
  const width = Math.max(maxLongitude - minLongitude, Number.EPSILON);
  const height = Math.max(maxLatitude - minLatitude, Number.EPSILON);
  const scale = Math.min(142 / width, 88 / height);
  const offsetX = (180 - width * scale) / 2;
  const offsetY = (116 - height * scale) / 2;
  return shape.polygons
    .flatMap((polygon) => polygon.map((ring) => ring
      .map(([longitude, latitude], index) => {
        const x = offsetX + (longitude - minLongitude) * scale;
        const y = offsetY + (maxLatitude - latitude) * scale;
        return `${index === 0 ? "M" : "L"}${x.toFixed(1)} ${y.toFixed(1)}`;
      })
      .concat("Z")
      .join(" ")))
    .join(" ");
}

export function ProvinceShape({ slug, label }: { slug: string; label: string }) {
  const path = pathForProvince(slug);
  if (!path) return null;
  return (
    <svg className="province-shape" viewBox="0 0 180 116" role="img" aria-label={`Boundary outline of ${label}`}>
      <path d={path} fillRule="evenodd" />
    </svg>
  );
}
