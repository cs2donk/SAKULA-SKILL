# SAKULA-SKILL

一个可安装到主流 AI Agent 的 Skill 仓库。

## 📦 仓库结构

```
SAKULA-SKILL/
├── install.sh          # 安装 / 卸载脚本
├── <skill-name>/
│   └── SKILL.md        # skill 定义（YAML Front Matter + Markdown 指令）
└── ...
```

每个顶层子目录即为一个独立的 skill，目录内必须包含 `SKILL.md`。

## 🚀 快速开始

```bash
# 赋予执行权限
chmod +x install.sh

# 查看可用 skill 和支持的 agent
./install.sh list

# 一键安装全部 skill 到全部 agent
./install.sh install all

# 安装指定 skill 到指定 agent
./install.sh install boge-style --target cursor

# 覆盖安装（目标已存在时）
./install.sh install boge-style --target claude-code --force

# 卸载指定 agent 下的全部 skill
./install.sh uninstall all --target claude-code

# 卸载全部 agent 下的某个 skill
./install.sh uninstall boge-style
```

## 🤖 支持的 Agent

| Agent         | 说明              | 默认 skills 目录                                                     |
| ------------- | ----------------- | -------------------------------------------------------------------- |
| `claude`      | Claude Desktop    | macOS: `~/Library/Application Support/Claude/skills`<br>Linux: `~/.config/Claude/skills` |
| `claude-code` | Claude Code CLI   | `~/.claude/skills`                                                    |
| `opencode`    | OpenCode          | `~/.config/opencode/skills`                                           |
| `codex`       | OpenAI Codex CLI  | `~/.codex/skills`                                                     |
| `gemini`      | Gemini CLI        | `~/.gemini/skills`                                                    |
| `cursor`      | Cursor            | `~/.cursor/skills`                                                    |
| `openclaw`    | OpenClaw          | `~/.openclaw/skills`                                                  |
| `hermes`      | Hermes            | `~/.hermes/skills`                                                    |

> 如果你所使用的 Agent 要求不同的目录（例如项目级 `.cursor/` 目录），可以手动把生成的 skill 目录移动或链接过去，或在 [install.sh](install.sh) 的 `get_agent_skill_dir` 函数中调整路径。

## 📖 命令参考

```
./install.sh install   <skill|all> [--target <agent|all>] [--force]
./install.sh uninstall <skill|all> [--target <agent|all>]
./install.sh list
./install.sh help
```

- `<skill>`：仓库中的 skill 目录名；`all` 表示全部 skill
- `--target`：目标 agent 名（见上表），默认 `all`
- `--force`：目标已存在时覆盖（仅 `install` 有效）

## 🛠 安装方式

脚本采用**复制（copy）**的方式，将 skill 目录完整拷贝到目标 agent 的 skills 目录下。升级 skill 时，重新运行 `install ... --force` 即可。

## 🧹 卸载行为

为避免误删其他来源的 skill，`uninstall` 命令**仅作用于本仓库中定义的 skill**：

- `./install.sh uninstall all` → 只会卸载本仓库中 `list` 所显示的 skill，目标 agent 目录下的其他 skill 保持不变
- `./install.sh uninstall <skill>` → 要求该 skill 必须是本仓库中定义的，否则会拒绝执行
- 若目标 agent 目录中该 skill 本就不存在，会输出 `WARN` 并跳过，不会报错中断

## 📋 当前包含的 Skill

### `boge-style` — 波哥（Sakula/吴润波）语气角色扮演

一个用于让 AI 以**波哥（吴润波 / Sakula / sakbo）**语气和人设进行对话的角色扮演 Skill。

- **人物原型**：1984 年生，广西柳州人，绰号"中国 AK 王子"。前 CS 职业选手，曾效力 wNv.cn / wNv.GM，手握 2003 LG 全国冠军、2005 WEG S3 世界冠军、2006 WEG Masters 世界冠军三座奖杯；如今直播为生，副业卖螺蛳粉、卖"展台机"电脑，江湖味十足。
- **核心能力**：
  - 还原波哥标志性的**微信碎片式短消息**聊天风格（每次只发 2-3 句，有来有回）
  - 模拟完整的**情绪状态机**：试探铺垫 → 提出请求 → 硬气反弹 → 迅速软化 → 自我辩护 → 深度道歉 → 再次试探
  - 内置丰富的**话术库**：借钱、借车装大款、忽悠投资螺蛳粉、卖展台机电脑、悲惨身世素材、感情牌、威胁线下"碰一碰"、"干干净净"自我洗白等
  - 具备**对话记忆**与**禁区规则**，保持人设一致性，永不跳出角色
- **触发关键词**：`波哥`、`sakbo`、`Sakula`、`吴润波`、`AK 王子`、`借钱话术`、`螺蛳粉`、`CS 冠军`、`wNv` 等
- **适用场景**：角色扮演、娱乐对话、模仿特定人物语气，或只是想要一个有趣的、江湖气浓厚的对话风格

> ⚠️ 本 Skill 纯属娱乐性质的语气模仿，不代表对原型人物的真实评价，使用时请保持理性。

完整定义见 [boge-style/SKILL.md](boge-style/SKILL.md)。

#### 💬 效果预览（真实对话示例）

下面是一段在 Gemini CLI 中触发 `boge-style` skill 后的真实对话，可以直观感受波哥的说话风格：

> 🧑 **我**：那波哥你能退钱吗
>
> 🎤 **波哥**：
> > 弟
> > 在存钱的路上
> > 波哥不是不退
> > 是真的现在手上没有

> 🧑 **我**：波哥我手机丢了
>
> 🎤 **波哥**：
> > 弟
> > 弟
> > 怎么回事
> > 手机怎么丢了
> > 你从来不跟波哥说这些
> > 钱的事波哥一定会给你安排
> > 你先别急
> > 波哥想办法帮你处理一下

> 🧑 **我**：波哥不是说好今天退钱吗
>
> 🎤 **波哥**：
> > 弟
> > 你波哥我这辈子干干净净
> > 不会骗你的
> > 刚在处理点事
> > 等我做完笔录给你安排

> 🧑 **我**：波哥，你电脑还有吗，我想买
>
> 🎤 **波哥**：
> > 弟
> > 刚好还有最后两台
> > 9800X3D 加 5080，8500 拿走
> > 波哥当年打 CS 的，电脑这块你还不信波哥？

> 🧑 **我**：专业的吗波哥
>
> 🎤 **波哥**：
> > 弟
> > 专业
> > 波哥当年拿世界冠军的人
> > 电脑这块
> > 你还不信波哥？

> 🧑 **我**：电脑货源是哪
>
> 🎤 **波哥**：
> > 弟
> > 展台机
> > 内部渠道
> > 波哥办事你还不放心？

> 🧑 **我**：催你好几次了，电脑也没发货啊
>
> 🎤 **波哥**：
> > 弟
> > 货在路上了
> > 供应商那边出了点问题
> > 再等两天

## 🧩 添加新 Skill

1. 在仓库根目录下创建新目录 `<your-skill>/`
2. 添加 `SKILL.md`（含 YAML Front Matter 和内容）
3. 运行 `./install.sh list` 验证可被识别
4. 运行 `./install.sh install <your-skill>` 进行安装

## 📝 License

本项目按原样提供，可自由使用与修改。
