/** @type {import('tailwindcss').Config} */
export default {
  darkMode: ["class"],
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        ink: {
          50: "#f4f7f8",
          100: "#e3eaed",
          200: "#c5d3d9",
          300: "#9bb3bd",
          400: "#6a8d9b",
          500: "#4f7282",
          600: "#435e6c",
          700: "#3a4e5a",
          800: "#34434c",
          900: "#2e3a42",
          950: "#1a2228",
        },
        tide: {
          400: "#2dd4bf",
          500: "#14b8a6",
          600: "#0d9488",
          700: "#0f766e",
        },
        ember: {
          400: "#fb923c",
          500: "#f97316",
          600: "#ea580c",
        },
        signal: {
          critical: "#e11d48",
          high: "#ea580c",
          medium: "#ca8a04",
          low: "#2563eb",
          info: "#64748b",
        },
      },
      fontFamily: {
        display: ['"Fraunces"', "Georgia", "serif"],
        sans: ['"DM Sans"', "ui-sans-serif", "system-ui", "sans-serif"],
        mono: ['"IBM Plex Mono"', "ui-monospace", "monospace"],
      },
      boxShadow: {
        panel: "0 1px 0 rgba(255,255,255,0.04) inset, 0 18px 40px -24px rgba(0,0,0,0.55)",
      },
      backgroundImage: {
        "grid-fade":
          "linear-gradient(to right, rgba(45,212,191,0.05) 1px, transparent 1px), linear-gradient(to bottom, rgba(45,212,191,0.05) 1px, transparent 1px)",
        "hero-glow":
          "radial-gradient(ellipse 80% 50% at 50% -20%, rgba(20,184,166,0.25), transparent), radial-gradient(ellipse 60% 40% at 100% 0%, rgba(249,115,22,0.12), transparent)",
      },
      keyframes: {
        "fade-up": {
          "0%": { opacity: "0", transform: "translateY(12px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        "pulse-soft": {
          "0%, 100%": { opacity: "1" },
          "50%": { opacity: "0.55" },
        },
        "score-ring": {
          "0%": { strokeDashoffset: "100" },
          "100%": { strokeDashoffset: "var(--score-offset)" },
        },
      },
      animation: {
        "fade-up": "fade-up 0.55s ease-out both",
        "fade-up-delay": "fade-up 0.7s ease-out 0.12s both",
        "pulse-soft": "pulse-soft 2.4s ease-in-out infinite",
      },
    },
  },
  plugins: [],
};
