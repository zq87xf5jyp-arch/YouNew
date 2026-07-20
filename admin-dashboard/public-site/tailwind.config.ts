import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        navy: {
          950: "#020713",
          900: "#05111f",
          850: "#071a2d"
        },
        orange: {
          brand: "#ff6b00",
          soft: "#ff7a1a"
        },
        cyan: {
          brand: "#00d6e6"
        },
        text: {
          muted: "#aeb8c7"
        }
      },
      boxShadow: {
        glow: "0 0 48px rgba(0, 214, 230, 0.18)",
        orange: "0 0 54px rgba(255, 107, 0, 0.22)",
        phone: "0 28px 80px rgba(0,0,0,0.48)"
      },
      backgroundImage: {
        "site-radial":
          "radial-gradient(circle at 18% 6%, rgba(0,214,230,0.16), transparent 28rem), radial-gradient(circle at 86% 12%, rgba(255,107,0,0.16), transparent 26rem), linear-gradient(180deg, #020713 0%, #05111f 46%, #020713 100%)"
      }
    }
  },
  plugins: []
};

export default config;
