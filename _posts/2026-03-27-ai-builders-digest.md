---
layout: default
title: "AI Builders Digest — 2026年3月27日"
date: 2026-03-27
categories: digest
---

# AI Builders Digest — 2026年3月27日

---

## 📢 官方博客

### [Anthropic Engineering: Claude Code auto mode: a safer way to skip permissions](https://www.anthropic.com/engineering/claude-code-auto-mode)

Anthropic 发布了 Claude Code 的 **auto mode**，这是一个在安全性和便利性之间取得平衡的新权限模式。传统上，用户需要在 sandbox（安全但配置复杂）和 `--dangerously-skip-permissions`（零维护但无保护）之间选择。Auto mode 使用两层防护：

**输入层**：服务端的 prompt-injection probe 扫描工具输出，检测潜在的指令注入攻击

**输出层**：transcript classifier（基于 Sonnet 4.6）评估每个操作，分两阶段：快速单 token 过滤 + chain-of-thought 推理

**关键数据**：
- False positive rate: 从 8.5% 降至 0.4%
- False negative rate: 17%（在真实过度行为检测中）

这比完全没有防护的 `--dangerously-skip-permissions` 安全得多，但不应替代高风险环境中的人工审核。

**核心设计**：classifier 只看到用户消息和工具调用，剥离 assistant 的推理过程和工具输出，防止 agent 说服 classifier 做出错误决定。

---

## 🐦 X / Twitter

### [Anthropic Cat Wu](https://x.com/_catwu/status/2036852880624541938)

推出 Claude Code 的 **auto mode**，平衡了自主性和安全性。团队几乎所有人都在日常使用这个模式。现在已对 Claude for Team 用户开放！

---

### [Anthropic Thariq](https://x.com/trq212/status/2036959638646866021)

宣布 **iMessage 现已作为 OpenClaw 的 channel 可用**！这扩展了 AI agent 的消息投递渠道。

---

### [Box CEO Aaron Levie](https://x.com/levie/status/2036832183131033977)

**Jevons paradox 正在实时发生。** 非科技公司意识到他们现在可以承担之前无法进行的软件项目，因为 AI 让这成为可能。

- 营销团队将有工程师帮助自动化工作流
- 生命科学公司将自动化研究
- 小企业将第一次雇佣工程师构建数字化体验

只要 AI agent 还需要人类来 prompt、review、maintain，就需要人管理这些 agent。这就是为什么"不要学工程"的建议是错误的。

---

### [Andrej Karpathy](https://x.com/karpathy/status/2036836816654147718)（前 Tesla AI 总监、OpenAI 创始成员）

发现所有 LLM 的个人化功能都有一个共同问题：**memory 功能对模型来说太分散注意力了。**

两个月前的一个问题可能会被模型误解为你的深层兴趣，并在后续对话中不断提及。他推测这可能是因为训练时，context window 中的信息通常与任务相关，导致模型在测试时过度依赖 RAG 检索到的内容。

---

### [Cursor 设计师 Ryo Lu](https://x.com/ryolu_/status/2036886854805709097)

> 当 agent 让添加功能变得容易时，design 反而变得更加重要。角色不再只是推像素——而是决定什么应该存在、如何组合、人类如何保持控制、intelligence 如何变得清晰可信且有用。
>
> Taste、craft 和 judgment 一直是瓶颈。竞争不在于谁发布最快，而在于谁为人类做对了东西。

---

### [Replit CEO Amjad Masad](https://x.com/amasad/status/2037004600893472936)

Apple 对使用 Replit 构建的 app 接受率很高，这是对 AI 辅助开发工具的认可。

---

### [Vercel CEO Guillermo Rauch](https://x.com/rauchg/status/2036963706576527623)

**每家公司都将变成 AI factory，token 是生产单位。** 但 token 的使用追踪和计费与 SaaS 完全不同。

AI Gateway 现在解决了跨模型和 provider 的 metering 问题，只需要一个 `/v1/report` API 调用。

---

### [Y Combinator CEO Garry Tan](https://x.com/garrytan/status/2037055498974093629)

> 这个新时代最重要的事情之一是你要激进地使用 token 来创造卓越的东西。
>
> 如果你有 agency 和 taste，结果会很出色。AI 的 token credits 是让初创公司对任何背景的人都可及的重要组成部分。

---

### [Every CEO Dan Shipper](https://x.com/danshipper/status/2036827118915485942)

发布了与 Instagram 联合创始人、现任 Anthropic Labs 的 Mike Krieger 的深度访谈。

**讨论话题**：
- 如何构建真正 agent-native 的产品
- 与 Instagram 时代的区别（现在从想法到产品的周期从几个月缩短到几小时）
- Agent 构建的陷阱（可以快速添加功能，但可能缺乏 product coherence）
- Anthropic Labs 的团队结构（每个实验只有 2 个人：PM/designer + engineer）

---

### [Linear 产品负责人 Nan Yu](https://x.com/thenanyu/status/2037042617213481410)

呼吁将 design 重新定义为"为了实现特定目的而排列元素的计划"，而不是过度关注排列元素而忘记了目的。

---

### [OpenClaw 的 Peter Steinberger](https://x.com/steipete/status/2036824286988816737)

宣布新版 beta 发布，包含更好的 MS Teams 集成、OpenWebUI 支持等功能。

---

## 🎙️ 播客

### [Training Data: Biology's Waymo Moment — Ginkgo Bioworks CEO Jason Kelly](https://youtube.com/watch?v=g45Alfg7diw)

**核心观点**：过去 30 年的技术革命（互联网、社交媒体）对生物技术毫无意义，但 AI 是第一个真正改变科学基础的技术。AI + 自主实验室将彻底改变我们做科学的方式。

#### Jason Kelly 的故事

- 2008 年创立 Ginkgo Bioworks，目标是让 biology 可编程
- 前 6 年完全 bootstrap，2014 年通过 YC 获得第一笔 VC 投资
- Sam Altman 当时刚接管 YC，写了篇博客说 Silicon Valley 模式可以用于 deep tech

#### AI for Science 的突破

与 OpenAI 的合作项目中，他们让 AI model 控制自主实验室，优化无细胞蛋白合成。经过 6 轮实验设计，**beat state-of-the-art 40%**。

**关键**：model 不需要模拟 biology，只需要像科学家一样逻辑推理、设计实验、分析数据、得出结论。

#### 两个不公平优势

**1. 信息共享**
- 100 个 AI scientist 在同一个问题上工作，每天共享所有实验数据
- 传统科学中，你我要等 1-2 年才能通过论文看到对方的发现

**2. 成本效率**
- 当前科学经费 <5% 花在试剂上，其余都是人力、实验室空间等 overhead
- 自主实验室可以让 90% 成本用于试剂——**10x 的数据/美元比**

#### 自主实验室的挑战

不是技术问题，是 adoption。没人愿意第一个尝试。Ginkgo 有自己的研究团队，50 个科学家 dogfooding 他们的 50 个机器人系统。

**关键问题**：liquid handling（液体处理）和集成 1000+ 种 benchtop 设备。

#### 未来愿景

实验室变得更小而不是更大——更高利用率、更少设备、更密集布局。他们刚向美国能源部卖了 97 个机器人用于 AI for Science 的 Genesis 项目。

#### 对中国的担忧

3 年前 <5% 的 biotech drug discovery 来自中国，上个季度已达 40%。他们有同样多的科学家、同样聪明、成本更低。美国需要通过 AI + 自主实验室来加速科研。

#### 最有趣的观点

> 如果降低实验室成本，让普通人也能订购实验、让 AI 帮他们设计实验，会不会有数百万人想成为科学家？
>
> 就像 1960 年代人们认为小孩编程计算机是疯狂的一样。

**金句**：

> "AI + 自主实验室将改变我们做科学的基础，这对美国保持科技领先地位至关重要。这不是 incremental improvement，这是 fundamental shift。"

---

*Generated through the [Follow Builders skill](https://github.com/zarazhangrui/follow-builders)*
