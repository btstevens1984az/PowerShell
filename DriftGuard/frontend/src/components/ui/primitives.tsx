import * as React from "react";
import { cn } from "@/lib/utils";

export function Badge({
  className,
  children,
}: {
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
        className
      )}
    >
      {children}
    </span>
  );
}

export function Card({
  className,
  children,
}: {
  className?: string;
  children: React.ReactNode;
}) {
  return <div className={cn("panel p-5", className)}>{children}</div>;
}

export function Stat({
  label,
  value,
  hint,
  accent,
}: {
  label: string;
  value: React.ReactNode;
  hint?: string;
  accent?: string;
}) {
  return (
    <Card className="relative overflow-hidden">
      <div
        className={cn(
          "pointer-events-none absolute -right-6 -top-6 h-24 w-24 rounded-full opacity-20 blur-2xl",
          accent || "bg-tide-500"
        )}
      />
      <div className="text-xs font-medium uppercase tracking-wider text-ink-300">{label}</div>
      <div className="mt-2 font-display text-3xl font-semibold text-white">{value}</div>
      {hint ? <div className="mt-1 text-xs text-ink-400">{hint}</div> : null}
    </Card>
  );
}

export function EmptyState({ title, body }: { title: string; body?: string }) {
  return (
    <div className="rounded-2xl border border-dashed border-white/10 px-6 py-12 text-center">
      <div className="font-display text-lg text-white">{title}</div>
      {body ? <p className="mx-auto mt-2 max-w-md text-sm text-ink-300">{body}</p> : null}
    </div>
  );
}
