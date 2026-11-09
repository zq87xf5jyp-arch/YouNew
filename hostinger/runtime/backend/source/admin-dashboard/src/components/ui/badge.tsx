import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const badgeVariants = cva("inline-flex items-center rounded-md border px-2 py-0.5 text-xs font-semibold", {
  variants: {
    variant: {
      default: "border-primary/30 bg-primary/15 text-orange-200",
      secondary: "border-border bg-secondary text-secondary-foreground",
      success: "border-emerald-500/30 bg-emerald-500/15 text-emerald-200",
      warning: "border-yellow-500/30 bg-yellow-500/15 text-yellow-100",
      destructive: "border-destructive/30 bg-destructive/15 text-red-100",
      info: "border-cyan-500/30 bg-cyan-500/15 text-cyan-100"
    }
  },
  defaultVariants: {
    variant: "default"
  }
});

export interface BadgeProps extends React.HTMLAttributes<HTMLDivElement>, VariantProps<typeof badgeVariants> {}

export function Badge({ className, variant, ...props }: BadgeProps) {
  return <div className={cn(badgeVariants({ variant }), className)} {...props} />;
}
