"use client";

/* eslint-disable @next/next/no-img-element */
import { useEffect, useRef, useState } from "react";

type ViewportImageProps = { src: string; srcSet?: string; sizes: string; alt: string };
const placeholder = "data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=";

// A horizontal gallery should not download every offscreen city on first paint.
export function ViewportImage(props: ViewportImageProps) {
  const image = useRef<HTMLImageElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    if (!image.current) return;
    if (!("IntersectionObserver" in window)) { setVisible(true); return; }
    const observer = new IntersectionObserver((entries) => {
      if (entries.some((entry) => entry.isIntersecting)) {
        setVisible(true);
        observer.disconnect();
      }
    }, { rootMargin: "120px", threshold: 0 });
    observer.observe(image.current);
    return () => observer.disconnect();
  }, []);

  return <>
    <img ref={image} className="viewport-image" src={visible ? props.src : placeholder}
      srcSet={visible ? props.srcSet : undefined} sizes={props.sizes} alt={props.alt}
      loading="lazy" decoding="async" />
    <noscript><style>{".viewport-image{display:none!important}"}</style><img {...props} alt={props.alt} loading="lazy" decoding="async" /></noscript>
  </>;
}
