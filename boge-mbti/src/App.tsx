import { useState, useEffect, useMemo } from 'react';
import { questions, results, type Option } from './data';

function App() {
  const [step, setStep] = useState<'start' | 'quiz' | 'result'>('start');
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [score, setScore] = useState(0);
  const [animateState, setAnimateState] = useState('');
  const [currentAvatar, setCurrentAvatar] = useState('/1.jpg');
  const [activeQuestions, setActiveQuestions] = useState(questions);
  const [hiddenResultCode, setHiddenResultCode] = useState<string | null>(null);

  useEffect(() => {
    if (step === 'quiz') {
      setCurrentAvatar(Math.random() > 0.5 ? '/1.jpg' : '/2.jpg');
    }
  }, [currentQuestionIndex, step]);

  // 避免过度快速点击
  const [isAnswering, setIsAnswering] = useState(false);

  const startQuiz = () => {
    setStep('quiz');
    setCurrentQuestionIndex(0);
    setScore(0);
    setHiddenResultCode(null);
    setActiveQuestions([...questions].sort(() => Math.random() - 0.5));
  };

  const handleOptionClick = (option: Option) => {
    if (isAnswering) return;
    setIsAnswering(true);
    setScore(prev => prev + option.score);
    if (option.isHiddenTrigger) {
      setHiddenResultCode(option.isHiddenTrigger);
    }
    
    // 淡出动画效果
    setAnimateState('fade-out');

    setTimeout(() => {
      if (currentQuestionIndex < activeQuestions.length - 1) {
        setCurrentQuestionIndex(prev => prev + 1);
        setAnimateState('fade-enter');
        setIsAnswering(false);
      } else {
        setStep('result');
        setIsAnswering(false);
      }
    }, 400);
  };

  const currentQuestion = activeQuestions[currentQuestionIndex];

  const shuffledOptions = useMemo(() => {
    if (!currentQuestion) return [];
    return [...currentQuestion.options].sort(() => Math.random() - 0.5);
  }, [currentQuestion]);
  
  const getResult = () => {
    if (hiddenResultCode) {
      return results.find(r => r.code === hiddenResultCode) || results[0];
    }
    const res = results.find(r => score >= r.minScore && score <= r.maxScore);
    return res || results[0]; // fallback
  };

  return (
    <div className="glass-container">
      {step === 'start' && (
        <div className="fade-enter">
          <div className="boge-avatar-container">
            <div className="boge-avatar">😎</div>
          </div>
          <h1 className="title">波哥BOTI<br/>赛博防骗大测试</h1>
          <p className="subtitle">
            在这残酷的电竞江湖里，你能防住曾经的WEG冠军、“AK王子”吴润波的千层套路吗？<br />
            测试你的心智防御力，看看你是赛博ATM，还是反向爆金币的祖先！<br/>
            （共 {questions.length} 题）
          </p>
          <button className="start-btn" onClick={startQuiz}>
            不敢看不起波哥，马上测试！
          </button>
        </div>
      )}

      {step === 'quiz' && currentQuestion && (
        <div className={animateState || 'fade-enter'}>
          <div className="boge-avatar-container" style={{marginBottom: "20px"}}>
            <img 
               className="boge-avatar" 
               src={currentAvatar} 
               alt="boge avatar" 
               style={{objectFit: 'cover'}} 
            />
          </div>
          <div className="question-tracker">
            第 {currentQuestionIndex + 1} 局 / 共 {questions.length} 局
          </div>
          <div className="progress-bar">
            <div 
              className="progress-fill" 
              style={{ width: `${((currentQuestionIndex) / questions.length) * 100}%` }}
            ></div>
          </div>

          <div className="incident-title">🔫 {currentQuestion.incident}</div>

          {currentQuestion.imageUrl && (
            <div className="question-img-wrapper" style={{textAlign: "center", marginBottom: "15px"}}>
              <img 
                 src={currentQuestion.imageUrl} 
                 alt="evidence" 
                 style={{maxWidth: "100%", maxHeight: "250px", borderRadius: "8px", border: "1px solid rgba(255,255,255,0.1)"}} 
              />
            </div>
          )}
          
          <div className="quote-bubble">
            {currentQuestion.bogeQuote}
          </div>

          <div className="options-container">
            {shuffledOptions.map((opt, i) => (
              <button 
                key={i} 
                className="option-btn"
                onClick={() => handleOptionClick(opt)}
              >
                {opt.text.replace(/^[A-D][.．、]?\s*/, '')}
              </button>
            ))}
          </div>
        </div>
      )}

      {step === 'result' && (
        <div className="fade-enter">
          <div className="boge-avatar-container">
            <div className="boge-avatar">👑</div>
          </div>
          <h2 className="title" style={{fontSize: '1.5rem', marginBottom: '5px'}}>你的赛博江湖防骗评级：</h2>
          <div className="mbti-code">{getResult().code}</div>
          <div className="mbti-meaning" style={{ textAlign: 'center', fontSize: '1rem', color: '#94a3b8', marginBottom: '15px', letterSpacing: '1px' }}>
            ({getResult().codeMeaning})
          </div>
          <div className="result-title">{getResult().title}</div>
          
          <div className="result-desc">
            {getResult().description}
            <br/><br/>
            <strong style={{color: '#ec4899'}}>你的最终波哥防骗得分：{score} 分</strong>
          </div>

          <div className="boge-comment">
            {getResult().imageQuote}
          </div>

          <button className="restart-btn" onClick={startQuiz}>
            再给波哥一次机会（重新测试）
          </button>
        </div>
      )}

      <div className="github-footer">
        <a href="https://github.com/cs2donk/SAKULA-SKILL" target="_blank" rel="noopener noreferrer">
          ⭐️ Open Source on GitHub: SAKULA-SKILL
        </a>
        <br />
        <a href="https://space.bilibili.com/3546964257934084?spm_id_from=333.1007.0.0" target="_blank" rel="noopener noreferrer" style={{ marginTop: '10px', display: 'inline-block', color: '#fb7299' }}>
          📺 B站作者：donk666本人
        </a>
      </div>
    </div>
  );
}

export default App;
