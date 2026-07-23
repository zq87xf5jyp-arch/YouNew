import {
  AbsoluteFill,
  Composition,
  Easing,
  Img,
  Sequence,
  interpolate,
  staticFile,
  useCurrentFrame,
  useDelayRender,
  useVideoConfig,
} from "remotion";
import {Audio, Video} from "@remotion/media";
import {parseSrt, type Caption} from "@remotion/captions";
import {useCallback, useEffect, useMemo, useState} from "react";

const FPS = 30;
const DURATION_SECONDS = 140;
const ORANGE = "#F36B21";
const CYAN = "#52C7D9";
const NAVY = "#07111F";

type Props = {
  reviewDraft: boolean;
};

type SceneSpec = {
  from: number;
  to: number;
  image: string;
  clip: string;
  eyebrow: string;
  title: string;
  detail: string;
  accent: string;
  checklist?: string[];
};

const scenes: SceneSpec[] = [
  {
    from: 0,
    to: 8,
    image: "screenshots/01-home.png",
    clip: "clips/01-home.mp4",
    eyebrow: "A NEW START",
    title: "One country.\nToo many open tabs.",
    detail: "YouNew begins with the person, not a feature list.",
    accent: ORANGE,
  },
  {
    from: 8,
    to: 20,
    image: "screenshots/02-ai-assistant.png",
    clip: "clips/02-assistant-question.mp4",
    eyebrow: "LOCAL GUIDE MODE",
    title: "I have an address.\nWhat comes next?",
    detail: "A deterministic workflow grounded in structured YouNew content.",
    accent: "#8A63F6",
  },
  {
    from: 20,
    to: 45,
    image: "screenshots/03-newcomer-flow.png",
    clip: "clips/03-assistant-result.mp4",
    eyebrow: "A CLEAR SEQUENCE",
    title: "From uncertainty\nto ordered steps",
    detail: "The supported newcomer journey keeps prerequisites visible.",
    accent: CYAN,
    checklist: ["1  Municipal registration + BSN", "2  DigiD", "3  Health insurance", "4  Huisarts"],
  },
  {
    from: 45,
    to: 62,
    image: "screenshots/03-newcomer-flow.png",
    clip: "clips/04-bsn-guide.mp4",
    eyebrow: "PRACTICAL GUIDE",
    title: "What it means.\nWhat to prepare.",
    detail: "Structured guidance continues inside the app.",
    accent: CYAN,
  },
  {
    from: 62,
    to: 80,
    image: "screenshots/05-official-source.png",
    clip: "clips/09-government-bsn-source.mp4",
    eyebrow: "VERIFY OFFICIALLY",
    title: "Named sources\nstay visible",
    detail: "YouNew supports orientation. It does not replace government advice.",
    accent: ORANGE,
  },
  {
    from: 80,
    to: 87,
    image: "screenshots/06-map.png",
    clip: "clips/05-map.mp4",
    eyebrow: "INTERACTIVE MAP",
    title: "Life is bigger\nthan one checklist",
    detail: "Province and city context in one connected experience.",
    accent: CYAN,
  },
  {
    from: 87,
    to: 94,
    image: "screenshots/02-ai-assistant.png",
    clip: "clips/06-search.mp4",
    eyebrow: "SEARCH",
    title: "Find a guide\nor nearby help",
    detail: "A real BSN result from the app's indexed content.",
    accent: "#8A63F6",
  },
  {
    from: 94,
    to: 102,
    image: "screenshots/07-map-to-home.png",
    clip: "clips/07-rotterdam.mp4",
    eyebrow: "CITY CONTEXT",
    title: "Rotterdam\ninside the journey",
    detail: "An imported city view without municipal identity tiles.",
    accent: ORANGE,
  },
  {
    from: 102,
    to: 110,
    image: "screenshots/04-guide.png",
    clip: "clips/08-guide-categories.mp4",
    eyebrow: "CONNECTED CATEGORIES",
    title: "Housing. Work.\nHealth. Study.",
    detail: "The wider product appears only after the core journey is clear.",
    accent: CYAN,
  },
];

const audioClips = [
  {from: 0, src: "audio/01_home.mp3"},
  {from: 8, src: "audio/02_question.mp3"},
  {from: 20, src: "audio/03_ordered_route.mp3"},
  {from: 45, src: "audio/04_guide_source.mp3"},
  {from: 80, src: "audio/05_map.mp3"},
  {from: 87, src: "audio/06_search.mp3"},
  {from: 94, src: "audio/07_city.mp3"},
  {from: 102, src: "audio/08_categories.mp3"},
  {from: 110, src: "audio/09_creator_story.mp3"},
];

const OpeningScene: React.FC<{scene: SceneSpec}> = ({scene}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const duration = (scene.to - scene.from) * fps;
  const easeOut = Easing.bezier(0.16, 1, 0.3, 1);

  return (
    <AbsoluteFill style={{backgroundColor: NAVY}}>
      <Img
        src={staticFile(scene.image)}
        style={{
          position: "absolute",
          inset: -70,
          width: 2060,
          height: 1220,
          objectFit: "cover",
          filter: "blur(34px) saturate(0.9) brightness(0.38)",
          scale: interpolate(frame, [0, duration], [1.015, 1.055], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
          translate: interpolate(frame, [0, duration], ["-12px 6px", "12px -6px"], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      />
      <AbsoluteFill
        style={{
          background: "linear-gradient(90deg, rgba(2,7,15,.38), rgba(2,7,15,.70) 48%, rgba(2,7,15,.94))",
        }}
      />
      <div className="opening-grid">
        <div
          className="phone-shell opening-phone"
          style={{
            borderColor: `${ORANGE}70`,
            opacity: interpolate(frame, [10, 42], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
              easing: easeOut,
            }),
            scale: interpolate(frame, [0, duration], [0.98, 1.035], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
            translate: interpolate(frame, [0, duration], ["-8px 5px", "8px -5px"], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
          }}
        >
          <Video
            src={staticFile(scene.clip)}
            muted
            objectFit="cover"
            className="phone-image"
          />
        </div>
        <div className="opening-copy">
          <div
            className="opening-brand"
            style={{
              opacity: interpolate(frame, [0, 24], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: easeOut,
              }),
              scale: interpolate(frame, [0, 24], [0.9, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: easeOut,
              }),
            }}
          >
            You<span>New</span>
          </div>
          <div
            className="opening-message"
            style={{
              opacity: interpolate(frame, [fps, fps + 24], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: easeOut,
              }),
              translate: interpolate(frame, [fps, fps + 24], ["0px 24px", "0px 0px"], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: easeOut,
              }),
            }}
          >
            Moving to a new country...
          </div>
          <div
            className="opening-tagline"
            style={{
              opacity: interpolate(frame, [fps + 18, fps + 48], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
                easing: easeOut,
              }),
            }}
          >
            A clearer first step starts here.
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};

const ProductScene: React.FC<{scene: SceneSpec}> = ({scene}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const duration = (scene.to - scene.from) * fps;
  const opacity = interpolate(frame, [0, 10, duration - 10, duration], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const scale = interpolate(frame, [0, duration], [1.005, 1.04], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const panDirection = Math.floor(scene.from / 7) % 2 === 0 ? 1 : -1;
  const pan = interpolate(
    frame,
    [0, duration],
    [`${-7 * panDirection}px 5px`, `${7 * panDirection}px -5px`],
    {extrapolateLeft: "clamp", extrapolateRight: "clamp"},
  );
  const copyY = interpolate(frame, [0, 16], [28, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

  return (
    <AbsoluteFill style={{opacity, backgroundColor: NAVY}}>
      <Img
        src={staticFile(scene.image)}
        style={{
          position: "absolute",
          inset: -50,
          width: 2020,
          height: 1180,
          objectFit: "cover",
          filter: "blur(38px) saturate(0.75) brightness(0.24)",
          scale: interpolate(frame, [0, duration], [1.015, 1.055], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
          translate: pan,
        }}
      />
      <AbsoluteFill
        style={{
          background: "linear-gradient(90deg, rgba(2,7,15,0.22), rgba(2,7,15,0.76) 52%, rgba(2,7,15,0.97))",
        }}
      />
      <div className="scene-grid">
        <div className="phone-shell" style={{borderColor: `${scene.accent}66`}}>
          <Video
            src={staticFile(scene.clip)}
            muted
            objectFit="cover"
            className="phone-image"
            style={{scale, translate: pan}}
          />
        </div>
        <div className="scene-copy" style={{opacity, translate: `0 ${copyY}px`}}>
          <div className="eyebrow" style={{color: scene.accent}}>{scene.eyebrow}</div>
          <div className="scene-title">{scene.title}</div>
          {scene.checklist ? (
            <div className="checklist">
              {scene.checklist.map((item) => <div key={item}>{item}</div>)}
            </div>
          ) : null}
          <div className="scene-detail">{scene.detail}</div>
        </div>
      </div>
    </AbsoluteFill>
  );
};

const CreatorMontage: React.FC = () => {
  const frame = useCurrentFrame();
  const imageFrames = [
    "screenshots/01-home.png",
    "screenshots/03-newcomer-flow.png",
    "screenshots/06-map.png",
    "screenshots/07-map-to-home.png",
  ];
  const videoFrames = [
    "clips/01-home.mp4",
    "clips/03-assistant-result.mp4",
    "clips/05-map.mp4",
    "clips/07-rotterdam.mp4",
  ];
  const index = Math.min(imageFrames.length - 1, Math.floor(frame / 195));
  const local = frame - index * 195;
  const imageOpacity = interpolate(local, [0, 12, 183, 195], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const scale = interpolate(local, [0, 195], [1, 1.035], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const panDirection = index % 2 === 0 ? 1 : -1;
  const pan = interpolate(
    local,
    [0, 195],
    [`${-8 * panDirection}px 5px`, `${8 * panDirection}px -5px`],
    {extrapolateLeft: "clamp", extrapolateRight: "clamp"},
  );

  return (
    <AbsoluteFill style={{backgroundColor: "#03070D"}}>
      <Img
        src={staticFile(imageFrames[index])}
        style={{width: "100%", height: "100%", objectFit: "cover", filter: "blur(32px) brightness(0.28)", scale, translate: pan}}
      />
      <AbsoluteFill style={{background: "linear-gradient(90deg, rgba(3,7,13,.94), rgba(3,7,13,.42), rgba(3,7,13,.92))"}} />
      <div className="montage-layout" style={{opacity: imageOpacity}}>
        <div className="montage-copy">
          <div className="eyebrow" style={{color: ORANGE}}>HUMAN-DIRECTED · AI-ASSISTED</div>
          <div className="scene-title">A clearer first step<br />in the Netherlands</div>
          <div className="scene-detail">Product vision and decisions remained human-directed.</div>
        </div>
        <div className="montage-phone">
          <Video
            src={staticFile(videoFrames[index])}
            muted
            objectFit="cover"
            className="phone-image"
            style={{scale, translate: pan}}
          />
        </div>
      </div>
    </AbsoluteFill>
  );
};

const FinalCard: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 8], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const logoEnter = interpolate(frame, [0, 16], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const purposeEnter = interpolate(frame, [14, 34], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

  return (
    <AbsoluteFill className="final-card" style={{opacity}}>
      <div className="final-brand" style={{opacity: logoEnter, scale: interpolate(logoEnter, [0, 1], [0.9, 1])}}>You<span>New</span></div>
      <div className="final-tagline">A clearer first step in the Netherlands</div>
      <div className="final-purpose" style={{opacity: purposeEnter, translate: `0 ${interpolate(purposeEnter, [0, 1], [16, 0])}px`}}>
        Built for people starting a new life in the Netherlands.
      </div>
      <div className="credits">
        <div><b>Product vision and direction:</b> Ivan Chernikov</div>
        <div><b>Product and writing partner:</b> ChatGPT</div>
        <div><b>Engineering partner:</b> Codex</div>
      </div>
      <div className="build-week">BUILT FOR OPENAI BUILD WEEK</div>
    </AbsoluteFill>
  );
};

const CaptionLayer: React.FC = () => {
  const [captions, setCaptions] = useState<Caption[] | null>(null);
  const {delayRender, continueRender, cancelRender} = useDelayRender();
  const [handle] = useState(() => delayRender("Loading SRT captions"));
  const {fps} = useVideoConfig();

  const load = useCallback(async () => {
    try {
      const response = await fetch(staticFile("captions/video-captions-en.srt"));
      const text = await response.text();
      setCaptions(parseSrt({input: text}).captions);
      continueRender(handle);
    } catch (error) {
      cancelRender(error);
    }
  }, [cancelRender, continueRender, handle]);

  useEffect(() => {
    load();
  }, [load]);

  const entries = useMemo(() => captions ?? [], [captions]);

  return (
    <AbsoluteFill style={{pointerEvents: "none"}}>
      {entries.map((caption, index) => {
        const from = Math.round((caption.startMs / 1000) * fps);
        const duration = Math.max(1, Math.round(((caption.endMs - caption.startMs) / 1000) * fps));
        return (
          <Sequence key={`${caption.startMs}-${index}`} from={from} durationInFrames={duration} layout="none">
            <div className="caption-wrap">
              <div className="caption">{caption.text.trim()}</div>
            </div>
          </Sequence>
        );
      })}
    </AbsoluteFill>
  );
};

const ReviewWatermark: React.FC = () => (
  <div className="review-watermark">REVIEW DRAFT · REPLACE STILLS WITH SCREEN RECORDING</div>
);

export const YouNewBuildWeekVideo: React.FC<Props> = ({reviewDraft}) => {
  return (
    <AbsoluteFill style={{backgroundColor: NAVY}}>
      <Sequence durationInFrames={(scenes[0].to - scenes[0].from) * FPS}>
        <OpeningScene scene={scenes[0]} />
      </Sequence>
      {scenes.slice(1).map((scene) => (
        <Sequence
          key={`${scene.from}-${scene.title}`}
          from={scene.from * FPS}
          durationInFrames={(scene.to - scene.from) * FPS}
        >
          <ProductScene scene={scene} />
        </Sequence>
      ))}
      <Sequence from={110 * FPS} durationInFrames={790}>
        <CreatorMontage />
      </Sequence>
      <Sequence from={136.3 * FPS} durationInFrames={Math.round(3.7 * FPS)}>
        <FinalCard />
      </Sequence>
      {audioClips.map((clip) => (
        <Sequence key={clip.src} from={clip.from * FPS} layout="none">
          <Audio src={staticFile(clip.src)} />
        </Sequence>
      ))}
      <CaptionLayer />
      {reviewDraft ? <ReviewWatermark /> : null}
    </AbsoluteFill>
  );
};

export const MyComposition = () => {
  return (
    <Composition
      id="YouNewBuildWeekReview"
      component={YouNewBuildWeekVideo}
      durationInFrames={DURATION_SECONDS * FPS}
      fps={FPS}
      width={1920}
      height={1080}
      defaultProps={{reviewDraft: false}}
    />
  );
};
