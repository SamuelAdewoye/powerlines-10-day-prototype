// Powerlines Editorial Redline: no gamification, no feed, no motion—only a linear path from Secret to Power Move.
import { useEffect, useMemo, useState } from "react";
import {
  ArrowLeft,
  ArrowRight,
  BookOpen,
  Check,
  ListChecks,
  LockKeyhole,
  RotateCcw,
  X,
} from "lucide-react";
import ReflectionDashboard, { type ReflectionRecord } from "@/components/ReflectionDashboard";

type Screen = "welcome" | "secret" | "story" | "lessons" | "quiz" | "move" | "complete" | "reflection";

type Commitment = {
  note: string;
  timestamp: string;
};

type SavedPractice = {
  unlockedDay: number;
  firstPracticeAt?: string;
  responses: Record<number, string[]>;
  commitments: Record<number, Commitment>;
};

const STORAGE_KEY = "powerlines-10-day-practice";

const DAYS = [
  {
    secret: "ATTENTION IS THE FIRST TERRITORY YOU MUST GOVERN.",
    storyTitle: "THE DAY YOU STOPPED NOTICING",
    story: "You can lose a day without ever making a dramatic mistake. It happens through small surrenders: the tab you did not mean to open, the message you answered before you chose to, the opinion that became louder than your own. By evening, you are tired—but not always from work. Sometimes you are tired from being available to everything except the life you meant to lead.\n\nThe problem is not that distraction exists. The problem is that it begins to look normal when no one asks what it is costing. Attention is not a mood. It is a direction of force. What receives it begins to shape you.",
    lessons: [
      "Your attention decides what becomes emotionally important. What you revisit starts to feel true, urgent, or inevitable—even when it is only loud.",
      "Reclaiming attention is not about becoming perfectly focused. It is about noticing the moment your mind leaves your possession and choosing what happens next.",
      "The first useful question is simple: where did my attention go today, and did I send it there?",
    ],
    questions: [
      "What has been taking more of your attention than it deserves?",
      "When today did you feel most present and self-directed?",
      "What is one place you can reduce automatic access tomorrow?",
    ],
    move: "Choose one attention leak you can interrupt today. Put it out of reach for one hour, then spend that hour on one task, conversation, or piece of rest you chose on purpose.",
  },
  {
    secret: "IMPULSE IS NOT A COMMAND.",
    storyTitle: "THE GAP BEFORE THE ANSWER",
    story: "Someone sends a message that lands badly. Your body makes a decision before your mind catches up: reply now, explain yourself, prove something, leave the room, buy the thing, open the app. The urge feels immediate because it is. That does not make it wise.\n\nPower begins in the short space between the first feeling and the first action. You do not need to become emotionless to use that space. You only need to learn that the first response is not always the response you owe the world.",
    lessons: [
      "An impulse often promises relief, not resolution. It wants the discomfort to end quickly, whether or not the next action helps you.",
      "Pausing creates information. When you wait, you can tell the difference between what you feel, what happened, and what you want to do about it.",
      "A deliberate response is not slow because you are weak. It is slow because you are choosing the terms.",
    ],
    questions: [
      "Which impulse most often makes decisions for you?",
      "What feeling usually arrives just before that impulse?",
      "What would a ten-minute pause make possible?",
    ],
    move: "The next time you feel the urge to react immediately, set a ten-minute timer before acting. Name the feeling in one sentence. When the timer ends, choose your response rather than obeying the first one.",
  },
  {
    secret: "WHAT YOU REPEAT BECOMES THE EVIDENCE YOU BELIEVE.",
    storyTitle: "THE RECORD YOU ARE MAKING",
    story: "Identity is rarely decided by one grand declaration. It is built from the record you keep making in ordinary hours. Each avoided conversation, each kept promise, each choice to begin again becomes evidence. Over time, that evidence tells you what kind of person you are allowed to believe yourself to be.\n\nThis is why small actions matter without needing to be romanticized. They matter because repetition is persuasive. You do not need a perfect streak. You need a record that is honest enough to guide the next choice.",
    lessons: [
      "Habits are not only routines; they are arguments. They argue for the identity you are building through repetition.",
      "A single broken promise is not a verdict. The important question is whether you return to the standard after the break.",
      "Better evidence often starts smaller than your ambition. Make the next action easy to verify and hard to reinterpret.",
    ],
    questions: [
      "What repeated action is teaching you something unhelpful about yourself?",
      "What small action would give you better evidence this week?",
      "Where have you confused intensity with consistency?",
    ],
    move: "Choose one action that takes less than fifteen minutes and repeat it today at a specific time. Record it when it is done. Let completion be evidence, not a performance.",
  },
  {
    secret: "DISCOMFORT IS OFTEN THE PRICE OF A CLEAN DECISION.",
    storyTitle: "THE FEELING YOU KEEP NEGOTIATING WITH",
    story: "There are choices you already understand but keep delaying because the first step would be awkward, disappointing, or uncertain. You call it needing more time. Sometimes that is true. Sometimes you are trying to make a necessary decision feel painless before you allow yourself to make it.\n\nA clean decision does not promise comfort. It gives you a direction. The discomfort may remain for a while, but it no longer gets to sit in the chair reserved for the person choosing your life.",
    lessons: [
      "Avoidance can look thoughtful when it wears the language of preparation. Look for the action that keeps moving without ever arriving.",
      "Discomfort is not proof that a choice is wrong. It may be proof that the choice matters and changes what others can expect from you.",
      "You can be compassionate with yourself without making every difficult feeling a reason to delay.",
    ],
    questions: [
      "What decision have you been waiting to feel ready for?",
      "What discomfort are you trying to avoid by postponing it?",
      "What would make the next step clean rather than dramatic?",
    ],
    move: "Name one decision you have delayed. Take the smallest irreversible step toward it today: send the message, set the boundary, book the appointment, or remove the option that keeps you waiting.",
  },
  {
    secret: "SHAME GETS LOUDER WHEN IT IS LEFT UNEXAMINED.",
    storyTitle: "THE PRIVATE PROSECUTOR",
    story: "Shame is efficient at making every mistake feel like a permanent identity. It takes one missed deadline, one awkward exchange, one version of yourself you do not admire, and turns it into a case against your whole future. It speaks with certainty because certainty keeps you still.\n\nExamination interrupts that certainty. You can name what happened without pretending it did not matter. You can take responsibility without accepting a sentence that says you are only the worst thing you have done.",
    lessons: [
      "Shame says, 'this is what you are.' Responsibility says, 'this is what happened, and this is what I will do next.' The difference is action.",
      "When a thought is vague, it can become absolute. Specific language makes repair possible.",
      "You do not gain power by denying a mistake. You gain it by refusing to let the mistake become your only source of identity.",
    ],
    questions: [
      "What mistake are you still using as evidence against yourself?",
      "What are the plain facts, without the insult attached?",
      "What repair, learning, or boundary is still available to you?",
    ],
    move: "Write the plain facts of one mistake in three sentences. Then write one repair or lesson you can act on within seven days. Keep the statement factual; do not let it become a verdict.",
  },
  {
    secret: "CLARITY IS OFTEN A DECISION TO STOP PRETENDING.",
    storyTitle: "THE THING YOU ALREADY KNOW",
    story: "Confusion sometimes protects you from an answer you do not want to admit. You gather more opinions, revisit the same possibilities, and wait for certainty to arrive from somewhere outside you. But beneath the noise, there may already be a truth you have been quietly editing.\n\nClarity does not always feel bright. It can feel like the end of a familiar excuse. Its value is not that it makes the next move easy. Its value is that it stops you from calling a known direction a mystery.",
    lessons: [
      "More information is useful until it becomes a substitute for choosing. Notice when research no longer changes the decision.",
      "A clear answer can include uncertainty. You can know what matters before you know every outcome.",
      "Honesty becomes practical when it is paired with a next step. Otherwise it is only a confession.",
    ],
    questions: [
      "What truth have you been editing to keep your options open?",
      "What decision would become simpler if you said that truth plainly?",
      "What information do you actually need before you move?",
    ],
    move: "Finish this sentence in writing: 'The truth I have been avoiding is…' Then identify one action that follows from it. Take that action before you seek another opinion.",
  },
  {
    secret: "CONSISTENCY IS A RELATIONSHIP WITH YOUR OWN WORD.",
    storyTitle: "THE PROMISE YOU HEAR",
    story: "Every promise you make to yourself has an audience: you. When you repeatedly say you will begin tomorrow, reply later, leave earlier, or protect your time—and then do not—your own word starts to lose weight. This is not a reason to make grander promises. It is a reason to make cleaner ones.\n\nTrust returns through follow-through that can be seen. You do not need to become a different person overnight. You need to become someone whose next promise is small enough to keep and serious enough to matter.",
    lessons: [
      "Self-trust is practical. It is built when your future self has evidence that your present self can be relied upon.",
      "Overpromising is often another form of avoidance. It lets you enjoy the idea of change without accepting the size of the work.",
      "A modest commitment completed repeatedly creates more power than a dramatic plan abandoned privately.",
    ],
    questions: [
      "What promise to yourself has become easy to dismiss?",
      "How could you make the promise smaller and more specific?",
      "What would keeping it tell you about your own word?",
    ],
    move: "Make one promise for the next twenty-four hours that is measurable and modest. Put it in your calendar or on paper. Complete it before you make another promise to yourself.",
  },
  {
    secret: "A THOUGHT IS NOT A COMMAND, A FACT, OR A FORECAST.",
    storyTitle: "THE SENTENCE THAT MOVED IN",
    story: "Some thoughts arrive with the force of official news: I always ruin things. They will think I am ridiculous. It is too late. Because the sentence comes from inside you, it can sound more credible than it deserves. You follow it without noticing that it made a claim you never checked.\n\nYou do not have to argue with every thought. You can simply stop assigning it authority automatically. A thought can be present without becoming the person in charge of your next action.",
    lessons: [
      "The mind produces language quickly. Speed is not evidence of accuracy.",
      "Naming a thought as a thought gives you room to inspect its usefulness. 'I am having the thought that…' creates distance without denial.",
      "A more accurate sentence is often less dramatic and more actionable. It tells you what is happening, not who you are forever.",
    ],
    questions: [
      "Which recurring thought most often narrows your choices?",
      "What evidence supports it, and what evidence complicates it?",
      "What would a more accurate sentence sound like?",
    ],
    move: "Catch one limiting thought today. Write it exactly. Add the words 'I am having the thought that' before it, then take one useful action without waiting for the thought to disappear.",
  },
  {
    secret: "FEELINGS DESERVE INFORMATION, NOT AUTOMATIC AUTHORITY.",
    storyTitle: "THE SIGNAL AND THE STEERING WHEEL",
    story: "Feelings are real. They tell you when something has landed, when a need may be unmet, when a boundary may have been crossed, or when a memory is still active. But a feeling is a signal, not a complete instruction manual. If you hand it the steering wheel every time, it may drive you toward relief rather than where you want to go.\n\nThe practice is neither suppression nor obedience. It is listening closely enough to learn what the feeling knows, then choosing the action that fits your values and the facts.",
    lessons: [
      "A feeling can be valid without being the whole story. Its presence matters; its first interpretation may not be final.",
      "Naming the feeling precisely reduces its power to become a fog. Anger, disappointment, grief, jealousy, and fear each point to different work.",
      "Your values are most useful when a feeling is loud. They help you choose what you want to stand for after the signal has been heard.",
    ],
    questions: [
      "What feeling has been asking for your attention recently?",
      "What information might it be carrying?",
      "What action would honor both the feeling and your values?",
    ],
    move: "When a strong feeling arrives today, name it without explanation. Take three slow breaths. Then write one action you can defend tomorrow, even if the feeling changes by tonight.",
  },
  {
    secret: "RESPONSIBILITY IS THE MOMENT YOU STOP WAITING TO BE RESCUED.",
    storyTitle: "THE PART THAT IS STILL YOURS",
    story: "Responsibility is often misunderstood as blame. It is not a claim that you caused everything that happened to you. It is the decision to identify what remains in your hands, even when circumstances are unfair, disappointing, or outside your design.\n\nWaiting for someone else to change may be understandable. Building your entire future around that wait is still a choice. Responsibility names the part you can influence and begins there—not because it is easy, but because it is the only part from which power can grow.",
    lessons: [
      "Responsibility starts with distinctions: what is mine, what is not mine, and what can I influence from here?",
      "Blaming yourself for everything is not responsibility. It is another way to avoid seeing the actual lever available.",
      "Agency often looks ordinary: one call, one request, one boundary, one schedule change, one honest acknowledgment of the next step.",
    ],
    questions: [
      "Where are you waiting for someone or something else to make the next move?",
      "What part of the situation is genuinely yours to influence?",
      "What would taking responsibility look like without blaming yourself?",
    ],
    move: "Choose one situation that has felt stuck. Make two columns: 'not mine to control' and 'mine to influence.' Take one action from the second column before the day ends.",
  },
] as const;

const emptySavedState: SavedPractice = {
  unlockedDay: 1,
  responses: {},
  commitments: {},
};

function formatDay(day: number) {
  return String(day).padStart(2, "0");
}

function displayTimestamp(value?: string) {
  if (!value) return "Not yet committed";
  return new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
    year: "numeric",
    hour: "numeric",
    minute: "2-digit",
  }).format(new Date(value));
}

export default function Home() {
  const [screen, setScreen] = useState<Screen>("welcome");
  const [activeDay, setActiveDay] = useState(1);
  const [unlockedDay, setUnlockedDay] = useState(1);
  const [firstPracticeAt, setFirstPracticeAt] = useState<string | undefined>();
  const [responses, setResponses] = useState<Record<number, string[]>>({});
  const [commitments, setCommitments] = useState<Record<number, Commitment>>({});
  const [draftAnswers, setDraftAnswers] = useState(["", "", ""]);
  const [moveNote, setMoveNote] = useState("");
  const [indexOpen, setIndexOpen] = useState(false);
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    try {
      const stored = window.localStorage.getItem(STORAGE_KEY);
      if (stored) {
        const parsed = JSON.parse(stored) as SavedPractice;
        setUnlockedDay(Math.min(Math.max(parsed.unlockedDay || 1, 1), 10));
        setFirstPracticeAt(parsed.firstPracticeAt);
        setResponses(parsed.responses || {});
        setCommitments(parsed.commitments || {});
      }
    } catch {
      window.localStorage.removeItem(STORAGE_KEY);
    } finally {
      setHydrated(true);
    }
  }, []);

  useEffect(() => {
    const applyHashRoute = () => {
      if (window.location.hash === "#record") setScreen("reflection");
    };
    applyHashRoute();
    window.addEventListener("hashchange", applyHashRoute);
    return () => window.removeEventListener("hashchange", applyHashRoute);
  }, []);

  useEffect(() => {
    if (!hydrated) return;
    const saved: SavedPractice = { unlockedDay, firstPracticeAt, responses, commitments };
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(saved));
  }, [commitments, firstPracticeAt, hydrated, responses, unlockedDay]);

  const day = DAYS[activeDay - 1];
  const completedCount = useMemo(() => Object.keys(commitments).length, [commitments]);
  const reflectionRecords = useMemo<ReflectionRecord[]>(
    () => DAYS.map((item, index) => ({
      day: index + 1,
      secret: item.secret,
      questions: item.questions,
      answers: responses[index + 1] || ["", "", ""],
      commitment: commitments[index + 1],
    })).filter((record) => record.commitment || record.answers.some((answer) => answer.trim())),
    [commitments, responses],
  );
  const isFinalDay = activeDay === DAYS.length;

  useEffect(() => {
    const savedAnswers = responses[activeDay] || ["", "", ""];
    setDraftAnswers([...savedAnswers]);
    setMoveNote(commitments[activeDay]?.note || "");
  }, [activeDay, commitments, responses]);

  const startPractice = () => {
    setActiveDay(unlockedDay);
    setIndexOpen(false);
    setScreen("secret");
  };

  const openDay = (number: number) => {
    if (number > unlockedDay) return;
    setActiveDay(number);
    setIndexOpen(false);
    setScreen("secret");
  };

  const saveAnswers = () => {
    setResponses((previous) => ({ ...previous, [activeDay]: draftAnswers }));
    setScreen("move");
  };

  const commitPowerMove = () => {
    if (!moveNote.trim()) return;
    const timestamp = new Date().toISOString();
    if (!firstPracticeAt) setFirstPracticeAt(timestamp);
    setCommitments((previous) => ({
      ...previous,
      [activeDay]: { note: moveNote.trim(), timestamp },
    }));
    if (activeDay === unlockedDay && activeDay < DAYS.length) {
      setUnlockedDay(activeDay + 1);
    }
    setScreen("complete");
  };

  const restartDemo = () => {
    window.localStorage.removeItem(STORAGE_KEY);
    setUnlockedDay(1);
    setFirstPracticeAt(undefined);
    setResponses({});
    setCommitments({});
    setActiveDay(1);
    setIndexOpen(false);
    setScreen("welcome");
  };

  const nextScreen = () => {
    const sequence: Screen[] = ["secret", "story", "lessons", "quiz", "move"];
    const currentIndex = sequence.indexOf(screen);
    if (currentIndex >= 0 && currentIndex < sequence.length - 1) {
      setScreen(sequence[currentIndex + 1]);
    }
  };

  const previousScreen = () => {
    const sequence: Screen[] = ["secret", "story", "lessons", "quiz", "move"];
    const currentIndex = sequence.indexOf(screen);
    if (currentIndex > 0) setScreen(sequence[currentIndex - 1]);
    if (screen === "secret") setScreen("welcome");
    if (screen === "reflection") {
      window.history.replaceState(null, "", window.location.pathname);
      setScreen("welcome");
    }
  };

  const openReflection = () => {
    setIndexOpen(false);
    window.history.replaceState(null, "", "#record");
    setScreen("reflection");
  };

  return (
    <main className={`powerlines-app ${screen === "secret" ? "secret-surface" : ""}`}>
      <aside className="practice-rail" aria-label="Powerlines practice navigation">
        <button className="brand-button" onClick={() => { window.history.replaceState(null, "", window.location.pathname); setScreen("welcome"); }} aria-label="Return to Powerlines home">
          <img src="/manus-storage/powerlines-mark_fdeccc88.png" alt="Powerlines mark" className="brand-mark" />
          <span>P/</span>
        </button>
        {screen !== "welcome" && (
          <button className="rail-control" onClick={previousScreen} aria-label="Go back">
            <ArrowLeft size={20} strokeWidth={1.8} />
          </button>
        )}
        <div className="rail-spacer" />
        <button className="rail-control" onClick={openReflection} aria-label="Open private reflection record">
          <ListChecks size={20} strokeWidth={1.8} />
        </button>
      </aside>

      <section className="app-stage">
        {screen !== "welcome" && (
          <header className="day-header">
            <span>{screen === "reflection" ? "PRIVATE RECORD" : `DAY ${formatDay(activeDay)} / 10`}</span>
            <div className="header-progress" aria-label={`${completedCount} of 10 Power Moves committed`}>
              {DAYS.map((_, index) => <i key={index} className={commitments[index + 1] ? "done" : index + 1 === unlockedDay ? "active" : ""} />)}
            </div>
            <span>{screen === "reflection" ? `${completedCount} MOVES / LOCAL` : screen === "complete" ? "COMMITMENT RECORDED" : "10-DAY DEMO"}</span>
          </header>
        )}

        {screen === "welcome" && (
          <section className="welcome-screen" aria-labelledby="welcome-title">
            <div className="welcome-copy">
              <div className="eyebrow">SURVIVAL TO SOVEREIGNTY / FIRST 10 DAYS</div>
              <h1 id="welcome-title">POWERLINES<br /><em>ONE PRACTICE.</em></h1>
              <p className="welcome-intro">A strictly paced digital practice for attention, agency, and self-expression. The order is the work: one Secret, one diagnostic, one Power Move.</p>
              <div className="welcome-meta">
                <span>LOCAL-FIRST</span>
                <span>ONE SECRET A DAY</span>
                <span>NO BINGE MODE</span>
              </div>
              <div className="entry-map" aria-label="Daily practice sequence">
                <span>01 / SECRET</span><span>02 / STORY</span><span>03 / LESSONS</span><span>04 / DIAGNOSTIC</span><span>05 / POWER MOVE</span>
              </div>
              <button className="command-button" onClick={startPractice}>
                BEGIN DAY {formatDay(unlockedDay)} <ArrowRight size={18} />
              </button>
              <p className="prototype-note">Demo pacing: recording a Power Move opens the next day. Your reflections stay in this browser.</p>
            </div>
            <div className="welcome-art" aria-hidden="true">
              <img src="/manus-storage/powerlines-hero-redline_dfbd5dc5.jpg" alt="" />
              <div className="art-index">DAY<br />01—10</div>
            </div>
          </section>
        )}

        {screen === "secret" && (
          <section className="secret-screen" aria-labelledby="secret-title">
            <div className="secret-position">SECRET {formatDay(activeDay)} OF 10</div>
            <div className="redline" />
            <h1 id="secret-title">{day.secret}</h1>
            <div className="secret-footer">
              <span>THE PRINCIPLE COMES FIRST.</span>
              <button className="understated-command" onClick={nextScreen}>TAP TO CONTINUE <ArrowRight size={17} /></button>
            </div>
          </section>
        )}

        {screen === "story" && (
          <article className="reading-screen" aria-labelledby="story-title">
            <div className="content-label">THE STORY</div>
            <h1 id="story-title">{day.storyTitle}</h1>
            <div className="reading-copy">
              {day.story.split("\n\n").map((paragraph) => <p key={paragraph}>{paragraph}</p>)}
            </div>
            <div className="reading-footer">
              <span>READ UNTIL THE PRINCIPLE HAS WEIGHT.</span>
              <button className="command-button dark-command" onClick={nextScreen}>CONTINUE <ArrowRight size={18} /></button>
            </div>
          </article>
        )}

        {screen === "lessons" && (
          <article className="lessons-screen" aria-labelledby="lessons-title">
            <div className="content-label">POWER LESSONS</div>
            <h1 id="lessons-title">LET IT LAND.</h1>
            <div className="lesson-list">
              {day.lessons.map((lesson, index) => (
                <div className="lesson" key={lesson}>
                  <span>0{index + 1}</span>
                  <p>{lesson}</p>
                </div>
              ))}
            </div>
            <div className="reading-footer">
              <span>THE POINT IS NOT AGREEMENT. IT IS ACCURATE EXAMINATION.</span>
              <button className="command-button dark-command" onClick={nextScreen}>CONTINUE <ArrowRight size={18} /></button>
            </div>
          </article>
        )}

        {screen === "quiz" && (
          <section className="diagnostic-screen" aria-labelledby="quiz-title">
            <div className="content-label">POWER QUIZ / DIAGNOSTIC</div>
            <h1 id="quiz-title">DO NOT PERFORM.<br />EXAMINE.</h1>
            <p className="diagnostic-intro">Write what is true enough to work with. These responses remain in this browser for later reflection.</p>
            <div className="questions">
              {day.questions.map((question, index) => (
                <label className="question-field" key={question}>
                  <span>0{index + 1}</span>
                  <strong>{question}</strong>
                  <textarea
                    value={draftAnswers[index]}
                    onChange={(event) => {
                      const next = [...draftAnswers];
                      next[index] = event.target.value;
                      setDraftAnswers(next);
                    }}
                    placeholder="Write the answer you are willing to face."
                    rows={3}
                  />
                </label>
              ))}
            </div>
            <div className="reading-footer">
              <span>THREE ANSWERS. NO SCORE.</span>
              <button className="command-button dark-command" onClick={saveAnswers}>SAVE RESPONSES <ArrowRight size={18} /></button>
            </div>
          </section>
        )}

        {screen === "move" && (
          <section className="move-screen" aria-labelledby="move-title">
            <div className="content-label">POWER MOVE FOR TODAY</div>
            <h1 id="move-title">MAKE THE<br />NEXT MOVE<br /><em>VISIBLE.</em></h1>
            <div className="move-instruction">{day.move}</div>
            <label className="commitment-field">
              <span>I WILL DO THIS TODAY:</span>
              <textarea
                value={moveNote}
                onChange={(event) => setMoveNote(event.target.value)}
                placeholder="Name the action clearly enough to recognize it when you have done it."
                rows={3}
              />
            </label>
            <div className="commitment-row">
              <div className="commitment-state">
                <span className="square-indicator" />
                <span>COMMITMENT RECORDS A TIMESTAMP.</span>
              </div>
              <button className="command-button red-command" disabled={!moveNote.trim()} onClick={commitPowerMove}>
                MARK AS COMMITTED <Check size={18} />
              </button>
            </div>
          </section>
        )}

        {screen === "complete" && (
          <section className="completion-screen" aria-labelledby="completion-title">
            <img src="/manus-storage/powerlines-completion-field_bfae32e8.jpg" alt="" className="completion-art" />
            <div className="completion-content">
              <div className="content-label light-label">DAY {formatDay(activeDay)} / COMPLETE</div>
              <h1 id="completion-title">YOU MOVED<br />THROUGH<br /><em>THE WORK.</em></h1>
              <p>Your Power Move has been recorded at {displayTimestamp(commitments[activeDay]?.timestamp)}.</p>
              <div className="completion-actions">
                {!isFinalDay && activeDay < unlockedDay && (
                  <button className="command-button" onClick={startPractice}>OPEN DAY {formatDay(unlockedDay)} <ArrowRight size={18} /></button>
                )}
                {!isFinalDay && activeDay === unlockedDay && (
                  <button className="command-button" onClick={startPractice}>OPEN DAY {formatDay(unlockedDay + 1)} <ArrowRight size={18} /></button>
                )}
                {isFinalDay && <button className="command-button" onClick={openReflection}>REVIEW THE 10 DAYS <ListChecks size={18} /></button>}
                <button className="text-command" onClick={openReflection}>OPEN PRIVATE RECORD</button>
              </div>
            </div>
          </section>
        )}

        {screen === "reflection" && (
          <ReflectionDashboard
            records={reflectionRecords}
            commitments={commitments}
            unlockedDay={unlockedDay}
            firstPracticeAt={firstPracticeAt}
            onOpenDay={openDay}
            onOpenIndex={() => setIndexOpen(true)}
            onStart={startPractice}
          />
        )}
      </section>

      {indexOpen && (
        <div className="index-overlay" role="dialog" aria-modal="true" aria-label="Powerlines practice index">
          <section className="practice-index">
            <header className="index-header">
              <div>
                <div className="content-label">10-DAY PRACTICE INDEX</div>
                <h2>THE RECORD<br />SO FAR.</h2>
              </div>
              <button className="close-index" onClick={() => setIndexOpen(false)} aria-label="Close practice index"><X size={24} /></button>
            </header>
            <div className="index-summary">
              <div><strong>{completedCount}</strong><span>COMMITTED</span></div>
              <div><strong>{unlockedDay}</strong><span>OPEN</span></div>
              <div><strong>LOCAL</strong><span>STORAGE</span></div>
            </div>
            <div className="day-grid">
              {DAYS.map((item, index) => {
                const number = index + 1;
                const isOpen = number <= unlockedDay;
                const isDone = Boolean(commitments[number]);
                return (
                  <button
                    className={`index-day ${isOpen ? "is-open" : "is-locked"} ${isDone ? "is-done" : ""}`}
                    key={item.secret}
                    onClick={() => openDay(number)}
                    disabled={!isOpen}
                  >
                    <span>DAY {formatDay(number)}</span>
                    <strong>{item.secret}</strong>
                    <small>{isDone ? "COMMITTED" : isOpen ? "OPEN" : "LOCKED"}</small>
                    {!isOpen && <LockKeyhole size={17} />}
                  </button>
                );
              })}
            </div>
            <footer className="index-footer">
              <p>Powerlines has no cloud account in this prototype. Your writing is saved only in this browser.</p>
              <button className="reset-button" onClick={restartDemo}><RotateCcw size={15} /> RESET 10-DAY DEMO</button>
            </footer>
          </section>
        </div>
      )}
    </main>
  );
}
