// Powerlines Editorial Redline: the private record makes evidence legible without turning practice into a game or dashboard spectacle.
import { ArrowRight, BookOpen, Check, LockKeyhole } from "lucide-react";

export type ReflectionRecord = {
  day: number;
  secret: string;
  questions: readonly string[];
  answers: string[];
  commitment?: { note: string; timestamp: string };
};

type ReflectionDashboardProps = {
  records: ReflectionRecord[];
  commitments: Record<number, { note: string; timestamp: string }>;
  unlockedDay: number;
  firstPracticeAt?: string;
  onOpenDay: (day: number) => void;
  onOpenIndex: () => void;
  onStart: () => void;
};

function displayTimestamp(value?: string) {
  if (!value) return "—";
  return new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
    year: "numeric",
    hour: "numeric",
    minute: "2-digit",
  }).format(new Date(value));
}

function dateKey(value: string) {
  const date = new Date(value);
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
}

function calculateStreak(commitments: Record<number, { note: string; timestamp: string }>) {
  const committedDates = Object.values(commitments)
    .map(({ timestamp }) => dateKey(timestamp))
    .filter((value, index, list) => list.indexOf(value) === index)
    .sort();

  if (!committedDates.length) return 0;
  let streak = 1;
  let cursor = new Date(`${committedDates[committedDates.length - 1]}T12:00:00`);

  for (let index = committedDates.length - 2; index >= 0; index -= 1) {
    const previous = new Date(`${committedDates[index]}T12:00:00`);
    const difference = Math.round((cursor.getTime() - previous.getTime()) / 86400000);
    if (difference !== 1) break;
    streak += 1;
    cursor = previous;
  }
  return streak;
}

export default function ReflectionDashboard({
  records,
  commitments,
  unlockedDay,
  firstPracticeAt,
  onOpenDay,
  onOpenIndex,
  onStart,
}: ReflectionDashboardProps) {
  const completedCount = Object.keys(commitments).length;
  const streakCount = calculateStreak(commitments);

  return (
    <section className="reflection-screen" aria-labelledby="reflection-title">
      <header className="reflection-heading">
        <div className="reflection-intro">
          <div className="content-label">PRIVATE REFLECTION RECORD</div>
          <h1 id="reflection-title">THE EVIDENCE<br />YOU HAVE<br /><em>KEPT.</em></h1>
          <p>Review what you answered. Review what you committed to. This record exists to make patterns visible, not to turn your practice into a score.</p>
        </div>
        <aside className="evidence-panel" aria-label="Practice evidence">
          <div>
            <strong>{streakCount}</strong>
            <span>DAY STREAK</span>
          </div>
          <div>
            <strong>{completedCount}<small>/10</small></strong>
            <span>POWER MOVES COMMITTED</span>
          </div>
          <div>
            <strong>{firstPracticeAt ? displayTimestamp(firstPracticeAt).split(",")[0] : "—"}</strong>
            <span>FIRST PRACTICE</span>
          </div>
        </aside>
      </header>

      <div className="record-progress" aria-label="Ten-day Power Move progress tracker">
        {Array.from({ length: 10 }, (_, index) => {
          const number = index + 1;
          const committed = Boolean(commitments[number]);
          const current = number === unlockedDay;
          return (
            <div className={committed ? "recorded" : current ? "current" : "unopened"} key={number}>
              <span>DAY {String(number).padStart(2, "0")}</span>
              {committed ? <Check size={15} /> : current ? <i /> : <LockKeyhole size={13} />}
            </div>
          );
        })}
      </div>

      <div className="reflection-list">
        {records.length === 0 ? (
          <section className="empty-record">
            <div className="content-label">NO PRIVATE RECORD YET</div>
            <h2>THE FIRST ANSWER OPENS THE RECORD.</h2>
            <p>Day {String(unlockedDay).padStart(2, "0")} is ready. The record begins when you make your first response visible.</p>
            <button className="command-button dark-command" onClick={onStart}>BEGIN DAY {String(unlockedDay).padStart(2, "0")} <ArrowRight size={18} /></button>
          </section>
        ) : records.map((record) => (
          <article className="reflection-entry" key={record.day}>
            <header>
              <span>DAY {String(record.day).padStart(2, "0")} / {record.commitment ? "COMMITTED" : "DIAGNOSTIC SAVED"}</span>
              <button onClick={() => onOpenDay(record.day)}>REOPEN DAY <ArrowRight size={15} /></button>
            </header>
            <h2>{record.secret}</h2>
            <div className="answer-register">
              {record.questions.map((question, index) => (
                <div key={question}>
                  <span>Q{index + 1}</span>
                  <strong>{question}</strong>
                  <p>{record.answers[index]?.trim() || "No answer was recorded."}</p>
                </div>
              ))}
            </div>
            <div className={`move-record ${record.commitment ? "is-committed" : ""}`}>
              <span>POWER MOVE</span>
              <p>{record.commitment?.note || "Not yet committed."}</p>
              <small>{record.commitment ? `COMMITTED ${displayTimestamp(record.commitment.timestamp)}` : "RETURN TO THE DAY TO COMMIT."}</small>
            </div>
          </article>
        ))}
      </div>

      <footer className="reflection-footer">
        <span>{completedCount ? `${completedCount} OF 10 POWER MOVES HAVE BEEN RECORDED.` : "NO ACTION HAS BEEN RECORDED."}</span>
        <button className="command-button dark-command" onClick={onOpenIndex}>OPEN DAY INDEX <BookOpen size={18} /></button>
      </footer>
    </section>
  );
}
