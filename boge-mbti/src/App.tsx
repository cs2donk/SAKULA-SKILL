import { useState, useEffect } from 'react';
import { questions, results } from './data';

function App() {
  const [step, setStep] = useState<'start' | 'quiz' | 'result'>('start');
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [score, setScore] = useState(0);
  const [animateState, setAnimateState] = useState('');
  const [currentAvatar, setCurrentAvatar] = useState('/1.jpg');

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
  };

  const handleOptionClick = (optionScore: number) => {
    if (isAnswering) return;
    setIsAnswering(true);
    setScore(prev => prev + optionScore);
    
    // 淡出动画效果
    setAnimateState('fade-out');

    setTimeout(() => {
      if (currentQuestionIndex < questions.length - 1) {
        setCurrentQuestionIndex(prev => prev + 1);
        setAnimateState('fade-enter');
        setIsAnswering(false);
      } else {
        setStep('result');
        setIsAnswering(false);
      }
    }, 400);
  };

  const currentQuestion = questions[currentQuestionIndex];
  
  const getResult = () => {
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
          <h1 className="title">波哥MBTI<br/>赛博防骗大测试</h1>
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
            {currentQuestion.options.map((opt, i) => (
              <button 
                key={i} 
                className="option-btn"
                onClick={() => handleOptionClick(opt.score)}
              >
                {opt.text}
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
    </div>
  );
}

export default App;
