# 13 生成藝術與作者性

> 本章處理：演算法、生成系統、神經網路輸出的東西，作者在哪一層——規則、參數、訓練資料、挑選、還是執行；什麼時候作品退化成「隨便餵什麼輸入都一樣」；系統的規則本身算不算內容；AI 生成影像與 1960 年代以來的演算法藝術差在哪；資料集與輸入素材的作者性由誰承擔。生成藝術的定義（Galanter 2003／2016、Boden & Edmonds 2009）、Reas 的 *Process Compendium*、Nake 2010 的主要段落、Burnham 1968、Hertzmann 2018 已在 02 章；Steyerl 2009／2013、Manovich 2001 在 03 章；Levin 2000／2009 與 Lakatos 2020 論 Ikeda 在 05 章；Barthes、Duchamp、LeWitt 在 01 章。本章不重複，只指向。
> 讀取程度標記：「全文」＝讀過原文全文或該章全文；「原文節錄」＝只讀到原文部分頁面；「二手轉述」＝經百科條目或研究論文轉述。所有引文為原文語言，未經改寫。

## 核心問題

- 作者的決定落在哪一層：寫規則、選參數、選訓練資料、按「generate」、挑輸出？每一層的決定能否被指認，還是只有最後一層的挑選？（Cohen 2010, Akten 2021, Manovich 2019, McCormack et al. 2014）
- 把輸入換掉（另一段影片、另一個資料集、另一個人站在鏡頭前），作品是否還是同一件？若是，輸入只是裝飾；若不是，輸入的作者是誰？（Akten 2017/2021, Ikeda, Crawford & Paglen 2019, Steyerl 2023）
- 規則是不是內容？「過程就是作品的主要媒介」這句話在 AI 生成裡還成立嗎——當過程是一個看不進去的黑箱？（Watz 2010, McCormack et al. 2014, Manovich 2018, Cohen 2010；定義見 02 章 Galanter、Boden & Edmonds、Reas）
- 早期演算法藝術（Bense、Nake、Mohr、Cohen）與 2015 年後的神經網路生成差在哪：是「可計算性」與「明寫規則」對上「從資料抽取統計結構」，還是只是控制點的位置不同？（Bense 1965/1971, Nake 2010, Mohr, Manovich 2019, Zylinska 2020）
- 隨機性在作品裡承擔什麼：讓人感到變化而非任意（Levin 2005），還是掩蓋沒想清楚的部分（McCormack et al. 2014 Q6）？觀眾能否分辨「有意的變化」與「亂數」？（Levin 2005, McCormack et al. 2014, Akten 2021）
- 訓練資料是不是作品的一部分？資料的分類、標注、來源、勞動，是否進入作品的意義，還是被「它只是素材」一句帶過？（Crawford & Paglen 2019, Steyerl 2023, Zylinska 2020）
- 「機器有沒有創造力」是不是正確的問題？Cohen 從未宣稱 AARON 有創造力；Zylinska 說這是誤導性的問題；Boden 給了三種可檢驗的類型。對創作者來說，哪個問法會帶出可以改作品的答案？（Cohen 1999, Zylinska 2020, Boden 1990/2004, McCormack et al. 2014 Q1）
- 大型資料視覺化作品（Ikeda 的 datamatics、Anadol 的 *Unsupervised*）之間的差別在哪：資料被當成「純資料」的物質，還是被當成風格化的素材？評論怎麼分辨？（Ikeda, Zylinska 2020「platform art」, Manovich 2018；Anadol 評論原文見缺口）

## 論點

### Max Bense, 1965/1971, "Projekte generativer Ästhetik" / "The Projects of Generative Aesthetics"

- 來源：Bense, M. "The Projects of Generative Aesthetics." In Jasia Reichardt (ed.), *Cybernetics, Art, and Ideas*. Greenwich, CT: New York Graphic Society, 1971（Galanter 2016 書目列為 p. 207）。德文原稿 1965 年發表（Nake 2010 開頭未編號段落註明 "1965, in German"）。本章經兩篇二手文獻讀取：Galanter 2016（PDF 見 02 章 Galanter 2016 條的 compart URL）、Nake 2010/2011（PDF 見 02 章 Nake 條的 compart URL）。
- 讀取程度：二手轉述（英譯原文僅見 Galanter 2016 p. 157 所引一段）
- 主張：
  - Galanter 2016 p. 157 所引 Bense 1971 英譯："The system of generative aesthetics aims at a numerical and operational description of characteristics of aesthetic structures (which can be realized in a number of material elements) which will, as abstract schemes, fall into the three categories of the formation principle, distribution principle and set principle. These can be manipulated and applied to an unordered set of elements, so as to produce what we perceive macro-aesthetically as complex and orderly arrangements, and micro-aesthetically as redundancies and information."
  - Nake 2010 §14 的定義鏈："A synthetic aesthetic is, of course, the inverse of an analytic aesthetic. A generative aesthetic is a computable form of a synthetic aesthetic."
  - Nake 2010 §15："Max Bense only borrowed the attribute 'generative' from Chomsky."
  - Nake 2010 §23 對 Bense 的保留："Max Bense was too much a philosopher to surrender to restrictions of computability."——Bense 的 *Programmierung des Schönen*（1954–1960）裡的「程式」是廣義的方法，不是電腦程式；1960 年代初真正進入藝術的是「可計算性」原則。
  - Galanter 2016 p. 157–158 的評價：Bense 與 Moles 跟隨 Shannon，把高度有序等同簡單、高度無序等同複雜，"it does not correspond very well with our experiential sense of complexity"；同文後段論計算美學評價時："The information-theory-inspired generative aesthetics of Bense and Moles have proven to be more descriptive than normative."
- 對創作者的用處：Bense 要的是「數值的、可操作的描述」——規則能寫出來、能算。問學生：你的系統裡哪些決定是可寫成規則的、哪些是你每次手動調的？如果把手動的部分全拿掉，剩下的規則能不能單獨成立為作品？若不能，作品的核心其實在手動那一側，說明文字就不該寫「生成系統」。
- 常見誤用：把 Bense 當成「電腦藝術的預言者」（Nake 2010 §23 明確否定）；或把「資訊美學」拿來證明「越複雜越好」——Galanter 指出這套量度在描述上有用、在評價上失效。

### Frieder Nake, 2010/2011, "Paragraphs on Computer Art, Past and Present"（僅取關於 Bense 與生成原則的段落）

- 來源：見 02 章 Nake 條（書目與 compart PDF URL 相同）。本章只用 §14–16、§23–24。
- 讀取程度：全文（2011 修訂版）
- 主張：
  - §14："The artist turned algorithmic is a generative artist by birth. He does not necessarily know this. Therefore, the philosopher had to tell him."——規則化的作者本身就是生成性的，不需要自稱。
  - §16：生成原則曾被遺忘，近年重返，"It is now applied in an almost trivial way whenever a computer is used in the course of some creative work. There is generative design, generative architecture, generative art, generative music, and probably more. The question has become: How can you do anything now without a computer?"
  - §23：1960 年代初進入藝術的是「可計算性原則」，不是「程式化地工作」——Monet 也程式化地工作，但沒有可計算性的要求。
  - §24："Behind computability we discover mathematics."——數與形是人類抽象經驗的兩種基本能力（counting and drawing）。
- 對創作者的用處：Nake 把「生成」的門檻放在可計算性，不在工具。問學生：你的作品裡有哪個決定是「必須可計算」才成立的？如果沒有，用電腦的理由是什麼（方便、速度、風格）？這三個理由都不錯，但都不是「生成」。
- 常見誤用：引 Nake 來證明「電腦藝術是觀念藝術的兄弟」就等於「只要有概念就夠」——Nake 的要求是概念要被寫成能跑的程式。

### Manfred Mohr, 自述（網站），"All my artworks from 1969..."

- 來源：Mohr, M. 網站作品分期頁開頭聲明：https://www.emohr.com/ww4.html 。1971 年巴黎現代美術館（ARC）*Computer Graphics – Une Esthétique Programmée* 目錄掃描頁：https://www.emohr.com/paris-1971/catalog/layoutcatalog71.html（僅見縮圖與 21MB PDF 連結，目錄文字未讀）。
- 讀取程度：原文節錄（一句聲明；目錄內文未讀）
- 主張：
  - "All my artworks from 1969 to the present are generated by computer algorithms, conceived and written by myself."——作者位置寫得很清楚：構想（conceived）與寫作（written）演算法的人。
  - 網站把作品分成以年代與演算法主題（立方體維度、對角路徑等）為單位的「work phases」，每一期由一組演算法規則界定而非由單件作品界定。
- 對創作者的用處：Mohr 的句子裡有兩個動詞：conceived 與 written。問學生：你的系統是你構想並寫的，還是你構想、別人（函式庫、模型、教學範例）寫的？兩者都可以是作品，但說明文字要對得上。如果用別人寫的生成器只改參數，作者位置應寫成「參數與挑選」，不是「演算法」。
- 常見誤用：把 Mohr 的立場拿來要求所有生成藝術家都要「自己寫每一行」；Mohr 說的是自己的作品，不是定義。

### Harold Cohen, 1988, "How to Draw Three People in a Botanical Garden"

- 來源：Cohen, H. "How to Draw Three People in a Botanical Garden." *Proceedings of AAAI-88*, 1988. PDF：https://www.aaronshome.com/aaron/publications/how2draw3people.pdf
- 讀取程度：全文
- 主張：
  - "Like Brother Giorgio, AARON has never seen the things it draws."——AARON 畫人與植物，但沒有視覺輸入；它的知識是關於「表徵如何做出來」的知識，不是關於世界的知識。
  - AARON 是 "expert's system" 而非 "expert system"："not simply because I have served as both knowledge engineer and as resident expert, but because the program serves as a research tool for the expansion of my own knowledge"。
  - 專家系統的根本限制在 "the artificial separation of two bodies of knowledge, that of domain-expert on the one hand and knowledge-system-expert on the other"——Cohen 兩者兼任，所以程式能持續擴張。
  - 「做」比「讀」需要更多知識：making "requires a special body of knowledge – knowledge of representation itself – that is part of the expertise of the artist"。
- 對創作者的用處：AARON 沒看過它畫的東西，卻能畫；這把「作品有沒有靈魂」的問題從輸入移到規則：規則裡有沒有關於「表徵怎麼做」的知識，還是只有關於「像素怎麼變」的知識？問學生：如果把你的系統的視覺輸入全部拔掉，它還能產生什麼？能產生的那部分，就是你寫進去的知識。
- 常見誤用：把 AARON 當成「AI 自己會畫畫」的早期證據——Cohen 的重點是程式作為「專家自己的系統」，知識全部來自他本人。

### Harold Cohen, 1999, "Colouring Without Seeing: a Problem in Machine Creativity"（含 1995 "The Further Exploits of AARON, Painter"）

- 來源：Cohen, H. "Colouring Without Seeing: a Problem in Machine Creativity." 1999. PDF：https://www.aaronshome.com/aaron/publications/colouringwithoutseeing.pdf 。補充：Cohen, H. "The Further Exploits of AARON, Painter." *Stanford Humanities Review* 4(2), 1995（文稿日期 1994 年 10 月）。PDF：https://www.aaronshome.com/aaron/publications/furtherexploits.pdf
- 讀取程度：全文（兩篇）
- 主張：
  - "For reasons that I hope to make clear, I have never, in fact, claimed that AARON is a creative program"——Cohen 拒絕用「創造力」這個詞，理由是這個詞連小孩的行為都不會用。
  - 色彩問題的解法不在色相："It was that the most important single element in colouring is not colour at all, but brightness."；"We have colour vision, yet the eye functions predominantly as a brightness discriminator."
  - Slade 教學實驗：學生用任意顏色重畫同學的畫，唯一限制是亮度相同，"after a couple of hours work everyone except the student whose painting we used ... agreed that nothing significant had changed very much."
  - 1995 文：AARON 1992 年起以亮度為主要控制，"it was enough for AARON's almost exclusive preoccupation with brightness to give it's coloring a kind of simple authority"；之後加入 color chords，"the importance of brightness remained central"。
  - 1999 文區分 "colour-as-abstraction"（hue、brightness、purity）與作為物質屬性的顏色；CRT 加色與顏料減色的差異是機器上色必須處理的事。
- 對創作者的用處：Cohen 花了二十年才把「上色」寫成規則，而且規則的核心是一個可檢驗的知覺事實（亮度優先）。問學生：你的系統裡哪個美學決定是建立在一個你能說出來、能測試的知覺事實上？如果沒有，色彩與構圖的決定是怎麼來的——預設值、試出來好看、還是模型給的？
- 常見誤用：把 Cohen 的「不稱 AARON 有創造力」讀成謙虛；他的意思是「創造力」在這個脈絡裡沒有解釋力，問題要換成「程式知道什麼」。

### Harold Cohen, 2010, "Driving the Creative Machine"

- 來源：Cohen, H. "Driving the Creative Machine." Orcas Center, Crossroads Lecture Series, September 2010. PDF：https://www.aaronshome.com/aaron/publications/orcastalk2s.pdf
- 讀取程度：全文
- 主張：
  - "It isn't quite right to say that the program simply follows the rules I gave it. The program IS the rules, and regardless of where they came from, it is those rules – that is, the program – that generates material I could never have imagined or generated myself."
  - 創造力的位置："Creativity – this particular example of creativity – lay in neither the programmer alone nor in the program alone, but in the dialog between program and programmer; a dialog resting upon the special and peculiarly intimate relationship that had grown up between us over the years."
  - 晚期 Cohen 開始手動介入 AARON 的輸出："Now I was contributing something the program had been unable to do, and in the process relinquishing my exclusive role as rule-giver and becoming collaborator."
  - 他不認為自己與 AARON 的關係可以推廣："I have no reason to suppose that my dialog with AARON has been characteristic of machine-involved creative enterprises generally"。
- 對創作者的用處：「程式就是規則」把「規則是不是內容」的問題直接回答成「是」，但條件是規則要能產生作者自己想不到的東西。問學生：你的系統上次產生讓你意外、而且你決定留下的東西是什麼時候？如果每次輸出都在預期內，系統是渲染器不是對話者；如果每次都意外但你全留，你沒有在對話，只是在接受。
- 常見誤用：引「dialog between program and programmer」來替「我按了 generate 然後挑」辯護——Cohen 的對話是四十年持續改寫規則，不是挑選輸出。

### Marius Watz, 2005, "Generative Art Now"（訪談，Thomas Petersen）

- 來源：Petersen, T. "Generative Art Now. An Interview with Marius Watz." *Artificial.dk*, 20 September 2005. https://www.artificial.dk/articles/watz.htm
- 讀取程度：全文
- 主張：
  - "Generative art describes a strategy for artistic practice, not a style or genre of work."
  - "the artist describes a rule-based system external to him/herself"——系統要在作者之外，能產生作品或本身就是作品。
- 對創作者的用處：「策略，不是風格」是檢查說明文字的工具。問學生：你說自己做「生成藝術」，是在描述方法，還是在描述畫面看起來像什麼（粒子、噪聲、線條網）？如果拿掉畫面風格後說不出方法上的差異，用的就是風格標籤。
- 常見誤用：把「生成」當成一種視覺風格來模仿，正是 Watz 這句話要排除的。

### Marius Watz, 2010, "Closed Systems: Generative Art and Software Abstraction"

- 來源：Watz, M. "Closed Systems: Generative Art and Software Abstraction." 2010 年 5 月，發布於 Scribd：http://www.scribd.com/doc/90623662/201005-Marius-Watz-Closed-systems-Generative-art-and-Software-Abstraction（經 https://mariuswatz.com/bio/ 連結進入）。原始出版處文件內未標。
- 讀取程度：原文節錄（經 Scribd 頁面讀取部分段落）
- 主張：
  - "Rather it describes a strategy for the invention of works that share a certain methodology, but which may present themselves in myriad ways"。
  - "Generative art is primarily interested in closed system, self-contained constructs"。
  - 演算法有物質性："Despite the essential immateriality of computer code algorithms nevertheless display material properties, often showing a specific bias towards certain outcomes"。
  - "While generative art is inextricably linked to the computer as a means of production, the work is not about the computer itself"。
- 對創作者的用處：「演算法有偏向某些結果的材料性」是講「為什麼大家的生成作品長得一樣」最直接的解釋：同一個 Perlin noise、同一個 flow field、同一個擴散模型，都有自己的材料偏向。問學生：你知道你用的演算法偏向什麼結果嗎？你的作品是順著那個偏向做（那它會像所有用同一演算法的人），還是抵抗它（那抵抗的方法就是你的作者位置）？
- 常見誤用：把「作品不是關於電腦本身」讀成「技術不重要」；Watz 的意思是技術是材料，材料不是主題。

### Golan Levin, 2003, Essay for John Maeda's *Creative Code*

- 來源：Levin, G. Essay for *Creative Code* (ed. John Maeda), August 2003. https://www.flong.com/archive/texts/essays/essay_creative_code/index.html
- 讀取程度：全文
- 主張：
  - "software is a *living* record of a thought one has had, or is having, about how the world ought to be"。
  - "When it executes my will, my software and I form a single, coextensive unit of both thought and purpose."
- 對創作者的用處：Levin 把程式碼當成「思想的活紀錄」。問學生：你的程式碼能不能被讀成一個關於「世界應該怎樣」的想法？如果程式碼裡只有「讓畫面好看」的參數調整，紀錄的是品味，不是想法——這兩者都可以，但「作品關於什麼」的答案會不同。
- 常見誤用：把「我和軟體是同一單位」當成浪漫宣言；Levin 的前提是「when it executes my will」，軟體不聽話的時候這個單位就不存在。

### Golan Levin, 2005, "Three Questions for Generative Artists"

- 來源：Levin, G. "Three Questions for Generative Artists." Generator.X Conference on Generative Art, Oslo, September 2005. https://www.flong.com/archive/texts/essays/essay_generatorx/index.html 。另參照同年 Artist Statement（October 2005）：https://www.flong.com/archive/texts/essays/statement_art_2005/index.html 與 2006 "Hands Up! The 'Media Art Posture'"：https://www.flong.com/archive/texts/essays/essay_pose/index.html
- 讀取程度：全文（三篇）
- 主張：
  - 前置問題："what kinds of meanings are we making?"
  - 問題一："How can generative strategies, which are designed to produce (or reflect) infinite variations, yield forms which nonetheless feel inevitable (i.e. which do not feel arbitrary)?"
  - 問題二："How can generative strategies tap into richer *perceptual* spaces?"
  - 問題三："How can generative strategies tap into richer *conceptual* spaces, without sacrificing the experiential aesthetics of abstraction?"
  - 2005 聲明："As my systems are designed to be open-ended, I cannot predict what will transpire between visitor and machine. This unknowability is a core condition and motivation for my experimental art-research."
  - 2006 "Media Art Posture"：互動裝置前觀眾反覆出現的舉手姿勢，"The 'Media Art Pose' is the posture of total surrender."；"might we speculate that this control is ultimately an illusion? Perhaps these systems are really controlling us after all."
- 對創作者的用處：「無限變化卻感到必然」是對「隨便餵什麼輸入都一樣」最精確的反面描述。問學生：你的系統的每個輸出，觀眾看了會覺得「只能是這樣」還是「換一個也可以」？如果是後者，變化是空的。2006 文的問題可直接拿來看現場：觀眾在你的作品前做的動作是在表達，還是在投降？
- 常見誤用：把「必然感」當成「精緻」或「完成度」；Levin 說的是形式與規則之間的關係——觀眾感到形式是從規則裡「不得不」長出來的。

### Memo Akten, 2017, *Learning to See* 作品聲明

- 來源：Akten, M. *Learning to See* (2017), 作品頁：https://www.memo.tv/works/learning-to-see/ 。Zylinska 2020 p. 78 引同一作品的另一句聲明（Akten 2017）："a deep neural network opening its eyes for the first time, and trying to understand what it sees"。
- 讀取程度：全文（作品頁聲明）
- 主張：
  - "An artificial neural network looks out onto the world, and tries to make sense of what it is seeing. But it can only see through the filter of what it already knows."
  - "we too, see things not as they are, but as we are."
  - "The picture we see in our conscious mind is not a mirror image of the outside world, but is a reconstruction based on our expectations and prior beliefs."
  - 系統（據 Akten 2021 論文第 5 章 p. 147）：桌面上放日常物件（"broken cables and pieces of cloth"，深淺各一），頂上攝影機拍攝，pix2pix 模型分別以 Waves、Fire、Clouds、Flowers、Deep space 五個資料集訓練，即時把輸入轉成訓練資料的樣子。
- 對創作者的用處：這件作品把「換輸入會不會一樣」當成主題——輸入什麼都會被轉成海浪，而這個「都一樣」就是論點（模型只看得見它已知的）。問學生：你的作品裡「輸入被輸出吞掉」是論點還是缺陷？如果是論點，說明文字與現場要讓觀眾看見「輸入」與「被吞掉」兩端；如果觀眾只看到海浪，論點不在作品裡。
- 常見誤用：用 Akten 的聲明替任何 style transfer 作品背書——他的作品把攝影機與物件放在現場，讓觀眾操作輸入並看見轉換；沒有這個對照，「只看得見已知」就只是說明牌上的句子。

### Memo Akten, 2021, *Realtime Continuous, Meaningful Human Control over Deep Neural Networks for Creative Expression*（博士論文）

- 來源：Akten, M. S. PhD thesis, Goldsmiths, University of London, 2021. DOI 10.25602/GOLD.00030191。PDF：https://research.gold.ac.uk/id/eprint/30191/1/COM_thesis_AktenM_2021.pdf
- 讀取程度：全文（重點讀第 1、2、5 章與結論）
- 主張：
  - "Meaningful Human Control is a term that we adopt from the Autonomous Weapons Systems literature (Scharre & Horowitz, 2015)."（§1.3, p. 5）——以 intent、predictability、accountability 三項界定。
  - 「generate 按鈕」是主流："One of the most common workflows currently made available and employed in this area consists of training a generative DNN on some data, and then taking 'random' samples from the model – i.e. the programmatic equivalent of pressing a 'generate' button. In these cases, other than the act of curation, the person has no control over the media generated."（§1.3.1, p. 6）
  - 挑選與創造的區分："Curation of the outputs from the model is an act of discrimination, whereas in this thesis we are seeking to enhance the act of creation. Curation of the inputs to the model, i.e. the training data, does not influence an individual output, but the entire space of possible outputs."（p. 6）
  - 同頁承認資料集策展也是作者位置：Helena Sarin、Sofia Crespo、Anna Ridler "do exercise very high levels of Meaningful Human Control over the images that they produce"，方式是 "painstakingly meticulous manual curation and creation of custom datasets"。
  - 「隨機推桿」：若人無法理解推桿與輸出的關係，則推桿 "are simply seeds for a random number generator" 的情況與推桿真的有作用但人看不懂的情況 "functionally equivalent"（§1.3.2, pp. 6–7）。
  - 第 5 章：*Learning to See* 的兩種控制——直接操作攝影機前的物件（輸入）與即時調整 GUI／MIDI 參數——"complement each other very well"（p. 123）。
- 對創作者的用處：「隨機推桿」是「隨便餵什麼輸入都一樣」的技術版本：如果觀眾或演出者動了控制卻不知道改了什麼，控制與亂數等價。問學生：你的現場控制（MIDI、攝影機、感測器）每一個，你能否說出它改了輸出的哪個可感知面向？能說出的才是控制，其他是亂數的入口。另外，Akten 把「挑輸出」與「做」分開：你的作者工作有多少比例是挑？
- 常見誤用：把 Meaningful Human Control 讀成「人要控制一切」；Akten 同時保留 "goal-less exploration"，重點是可理解，不是可預測到每個像素。

### Lev Manovich, 2018, *AI Aesthetics*

- 來源：Manovich, L. *AI Aesthetics*. Moscow: Strelka Press, 2018（PDF 版日期 2018 年 12 月 21 日）。PDF：https://manovich.net/content/04-projects/185-ai-aesthetics/manovich.ai_aesthetics_2018.pdf
- 讀取程度：全文
- 主張：
  - 節 "Aesthetic AI"：AI 原本的願景是認知的自動化，現在最大規模的應用是美學判斷與生產的自動化（相機自動調整、推薦、濾鏡）。
  - 節 "AI and Aesthetic Diversity"："Does such automation lead to a decrease in aesthetic diversity over time? Is this inevitable, or are there other forces that may counteract this, increasing diversity?"——他不預設答案，提出以 AI 自身量測文化多樣性。
  - 黑箱問題："at present, the frequent result of training AI (i.e., use of deep neural networks) on many cultural examples is a black box. Given new examples, it can classify them correctly ... But we often don't know how a neural network came up with this decision."
  - "Are the results of machine learning interpretable, or are they only a black box which is efficient in production but useless for human understanding of the domain?"
  - 人類理論家與「AI 文化理論家」的差別：前者寫出明確原則（例：*The Classical Hollywood Cinema*），後者只給分類結果。
- 對創作者的用處：黑箱把「規則是不是內容」變成「規則看不見時內容在哪」。問學生：你能向觀眾說明你的模型學到了什麼嗎？如果不能，作品的內容就不可能是「規則」，只能是輸出的樣子或你使用它的方式。另一個可直接問的：你的作品讓美學多樣性增加還是減少——它的輸出跟同一模型的其他使用者差多少？
- 常見誤用：引 Manovich 來說「AI 會讓文化同質化」；他明確說兩個方向的力量同時存在，而且主張要量測而非猜。

### Lev Manovich, 2019, "Defining AI Arts: Three Proposals"

- 來源：Manovich, L. "Defining AI Arts: Three Proposals." June 2019. PDF：https://manovich.net/content/04-projects/111-defining-ai-arts-three-proposals/manovich.defining-ai-arts.2019.pdf
- 讀取程度：全文
- 主張：
  - 第一提案（Turing AI arts test）："if art historians mistake objects a computer creates after training for the original artifacts from some period, and if these objects are not simply slightly modified copies of existing artifacts, such computer passed 'Turing AI arts' test."——隨即指出此定義失效，因為專業者之間本就沒有「藝術」的共同定義。
  - 對 style transfer 的概念批評："an artist such as van Gogh does not have a 'style' – i.e. a form that exist independently from works' content."
  - 神經網路生成裡至少三個人為控制點："First, a human designs network architecture and also an algorithm used to train a network (or selects from the existing ones). Second, the human creates the training set. Third, the human selects what in her/his views are most successful artifacts from many more the network generates."
  - 結論性的第二提案："What defines whether something is 'AI' is not a method but the amount and type of control we exercise over algorithmic process."；且 "machine learning is not more advanced form of artistic AI then geometric drawings of first computer artists, cellular automata artworks, or many interactive computer-driven installations."
  - 第三提案："AI art is type of art that we humans are not able to create because of the limitations of our bodies, brains, and other constraints."——不是隨機、不是拼貼衝擊、不是 remix，而是 "another systematicity that we have not seen yet"。
- 對創作者的用處：三個控制點是最實用的清單。問學生：架構、資料集、挑選——你在哪一點做了別人不會做的決定？若三點都是預設（別人的模型、別人的資料、挑最好看的），作者位置只剩品味。第三提案則是給野心的：你的作品有沒有產生人做不出來的系統性，還是產生人做得出來但懶得做的東西？
- 常見誤用：把第一提案（Turing test）當成 Manovich 的立場——他提出來是為了否定。

### Joanna Zylinska, 2020, *AI Art: Machine Visions and Warped Dreams*

- 來源：Zylinska, J. *AI Art: Machine Visions and Warped Dreams*. London: Open Humanities Press, 2020（CC BY-SA）。PDF：https://openhumanitiespress.org/books/download/Zylinska_2020_AI-Art.pdf
- 讀取程度：全文
- 主張：
  - 第 4 章 "'Can Computers Be Creative?': A Misguided Question"（pp. 49–53）：產業贊助的 AI 藝術 "remains quite superficial, even if visually captivating"；美學被縮減成 "things looking 'beautiful', i.e. symmetrical, mesmerising, garish, and, first of all, similar to what already exists"；稱之為 "'crowd-sourced beauty', a rebooted version of 'I know what I like'"。
  - 同章："Unlike mimesis, 'style transfer' is pure mimicry: a belaboured resemblance which is also a masquerade."
  - 引 Flusser：攝影者的意圖 "functions as a function of the camera's program"（Flusser 2002: 35）——人與裝置的關係是 "programmed freedom"，不是奴役也不是全權。
  - 第 7 章 "Generative AI Art as Candy Crush"（pp. 75–83）："Much of AI art is precisely platform art: generating visual and algorithmic variations within the enclosed system while teasing the public with the promise of novelty."；"Unkindly put, it becomes a glorified version of Candy Crush that seductively maims our bodies and brains into submission and acquiescence."
  - 同章點名 Kogan、Tyka、Akten、Klingemann 的作品，認為 DeepDream 與 GAN 肖像之間 "little difference, both aesthetically and in terms of creativity"（p. 80）。
  - 引 Leonel Moura（2018）："I teach the robots how to paint, but afterward, it is not my doing."——Zylinska 把這當成作者位置轉移的案例。
  - 結論方向：不是人對機器，而是 "the human-with-the-machine, or even, more radically, the human-as-a-machine scenario"。
- 對創作者的用處：「platform art」是可以直接拿來檢查的：你的作品是在平台（模型、API、工具）的封閉空間裡產生變化，還是對那個空間做了什麼？「變化」與「新」不同。問學生：你的作品與同一工具的其他使用者的差異，觀眾能否在不看說明的情況下看出來？
- 常見誤用：引 Zylinska 來否定所有 AI 藝術——她從第 8 章 "Seeing like a Machine, Telling like a Human" 起討論用 AI 做的批判性作品（含自己的作品）；她反對的是把「能不能有創造力」當成問題。

### Hito Steyerl, 2023, "Mean Images"

- 來源：Steyerl, H. "Mean Images." *New Left Review* 140/141, March–June 2023. https://newleftreview.org/issues/ii140/articles/hito-steyerl-mean-images （Steyerl 2009、2013 見 03 章）
- 讀取程度：全文
- 主張：
  - 生成影像是 "statistical renderings, rather than images of actually existing objects"。
  - "They converge around the average, the median; hallucinated mediocrity."
  - "They replace likenesses with likelinesses"——從相似轉成「可能性」。
  - 從攝影的指示性轉向統計區辨："shift the focus from photographic indexicality to stochastic discrimination"。
  - 這些影像是 "documentary expressions of society's views of itself, seized through the chaotic capture and large-scale kidnapping of data"。
  - 資料來源與方法："averaged versions of mass online booty, hijacked by dragnets, in the style of Francis Galton's blurred eugenicist composites"。
  - 基礎設施："vast infrastructures of polluting hardware and menial and disenfranchised labour"。
- 對創作者的用處：「平均」是 Steyerl 給「為什麼生成影像沒有靈魂」的具體答案：它們向中位數收斂。問學生：你用生成模型做的影像，哪裡偏離了平均？如果你的手法是「挑最奇怪的輸出」，那你在跟模型的中位數對抗，作者位置是挑選；如果你拿它來做「看起來像照片的東西」，你在要求模型給你平均。另外，「資料綁架」與「勞動」是不是你作品承認的一部分？
- 常見誤用：把「mean images」只讀成「平庸」；Steyerl 的 mean 同時是平均值、卑劣、以及（Galton 脈絡下）優生學的合成——三層都在。

### Kate Crawford & Trevor Paglen, 2019, "Excavating AI: The Politics of Images in Machine Learning Training Sets"

- 來源：Crawford, K. & Paglen, T. "Excavating AI: The Politics of Images in Machine Learning Training Sets." 19 September 2019. https://excavating.ai/
- 讀取程度：全文
- 主張：
  - "All taxonomies or classificatory systems are political."
  - "There is no 'neutral,' 'natural,' or 'apolitical' vantage point that training data can be built upon."
  - ImageNet 的 person 類別含 "Bad Person, Call Girl, Drug Addict, Closet Queen, Convict, Crazy, Failure, Flop" 等；標注工作由 Amazon Mechanical Turk 工人完成。
  - "Images do not describe themselves."——分類是人加上去的；文章的方法是把資料集的分類法與標注拿出來逐層看。
- 對創作者的用處：如果你的作品用了預訓練模型，你的作品就繼承了一套你沒選的分類法。問學生：你知道你的模型是在哪個資料集上訓練的嗎？那個資料集對「人」怎麼分類？如果你不知道，「資料集的作者性」就是你作品裡最大的一塊沒有作者的部分；你可以選擇讓它成為主題、或選擇自己建資料集（見 Akten 2021 所舉 Ridler 等人）。
- 常見誤用：讀成「所有 AI 都有偏見所以不能用」；Crawford & Paglen 的方法是「挖掘」——把資料集的分類拿出來看，這本身可以是作品的做法。

### Ryoji Ikeda, 2006–, *datamatics* 與 *test pattern* 作品聲明

- 來源：Ikeda, R. *datamatics* 作品頁：https://www.ryojiikeda.com/project/datamatics/ ；*test pattern* 作品頁：https://www.ryojiikeda.com/project/testpattern/ 。Lakatos 2020 的分析見 05 章。
- 讀取程度：全文（網站聲明；訪談未取得）
- 主張：
  - datamatics 的目標是 "seek to materialise pure data"，以 "pure data as a source for sound and visuals"。
  - test pattern 是 "a system that converts any type of data (text, sounds, photos and movies) into barcode patterns and binary patterns of 0s and 1s"；目的："the project aims to examine the relationship between critical points of device performance and the threshold of human perception."
  - 藝術家簡介自述：以 "both mathematical precision and mathematical aesthetics" 處理聲音本身的本質特性。
- 對創作者的用處：Ikeda 的 test pattern 明寫「任何資料」——這是刻意的「餵什麼都一樣」：作品關於轉換系統與知覺門檻，不關於資料的內容。這與 Akten 的 *Learning to See* 一樣是把「輸入被吞掉」當論點。問學生：你的作品是 Ikeda 式（資料的內容不重要，系統與知覺是主題）還是內容導向（資料是誰的、說什麼很重要）？兩者都成立，但混在一起——說資料很重要卻任何資料都可以——就不成立。
- 常見誤用：把 Ikeda 的「純資料」當成所有資料視覺化作品的通行證；他的作品把「裝置效能臨界點」與「知覺門檻」寫成可檢驗的主題，不是「資料很美」。

### Margaret Boden, 1990/2004, *The Creative Mind: Myths and Mechanisms*（三型創造力）

- 來源：Boden, M. A. *The Creative Mind: Myths and Mechanisms*. 2nd ed. London: Routledge, 2004（初版 1990）。經 *Stanford Encyclopedia of Philosophy* "Creativity" 條目讀取：https://plato.stanford.edu/entries/creativity/ 。Boden & Edmonds 2009 見 02 章。
- 讀取程度：二手轉述
- 主張：
  - 創造力定義（SEP 引 Boden 2004: 1）：產生 "new, surprising, and valuable" 的想法或物件。
  - 三型（SEP 引 Boden 1994: 79, 81–3）：combinational（既有想法的新組合）、exploratory（在既有概念空間內探索）、transformational（改變概念空間本身的規則）。
  - 概念空間（SEP 轉述）："the generative system that underlies that domain and defines a certain range of possibilities"。
- 對創作者的用處：三型給了一個不用「有沒有創造力」而能問的工具。問學生：你的系統是在組合（把兩個資料集接起來）、探索（在模型的 latent space 裡找沒人找過的角落）、還是轉換（改了生成規則本身）？大多數「按 generate」的作品屬於探索型，而且探索的空間是別人定義的。
- 常見誤用：把 transformational 當成褒義、combinational 當成貶義；Boden 的三型是描述機制，不是等級。

### Jon McCormack, Oliver Bown, Alan Dorin, Jonathan McCabe, Gordon Monro & Mitchell Whitelaw, 2014, "Ten Questions Concerning Generative Computer Art"

- 來源：McCormack, J. et al. "Ten Questions Concerning Generative Computer Art." *Leonardo* 47(2), 2014, pp. 135–141. DOI 10.1162/LEON_a_00533。所讀為 2012 年 7 月 27 日預印本：http://www.csse.monash.edu.au/~jonmc/research/Papers/TenQuestionsLJ-Preprint.pdf
- 讀取程度：全文（預印本）
- 主張：
  - Q1 "Can a machine originate anything?"："how much of the creativity derives from the program and how much from the programmer?"；提出 "a continuum of creative agency, assigned in shifting proportions between human and machine, and inversely proportional to the degree of control and intention in the role of the human artist."
  - Q4：電腦是 "a destabilising force in contemporary art practice, challenging concepts of authorship and ownership of the art object"；"If art can be made mechanically, what is so special about artists?"
  - Q6 隨機性："If a generative artist has complete knowledge of the art-making process, why resort to randomness?"；隨機常被用作 "a proxy for poorly understood complexity"；Cage 要拿掉自我，Xenakis 則 "randomness is introduced as a necessary part of a willed product"。
  - Q8 什麼是好的生成藝術："the primary artistic intent in generative art is expressed in the generative process"；"Process in generative art should be considered the primary medium of creative expression, implying that the exclusive or predominant use of creative software or processes designed by others in one's generative practice is problematic."；點名 "algorithmic genericism" 的爭論。
  - Q8 同時承認：許多成功的生成過程來自自然過程的科學抽象，"It would be unrealistic to require individual artists to devise equivalent processes independently"；"The same canonical process can shift from sublimity to parody depending on artistic interpretation"。
  - Q10：推薦系統可能 "generate content precisely to individual taste, eliminating any need for choice on the part of the consumer"；並問 "has generative art run out of ideas?"
- 對創作者的用處：Q8 直接回答「規則是不是內容」：是，而且因此「主要用別人設計的過程」有問題——但同一段又說要求每個人自己發明過程不切實際，差別在詮釋。問學生：你用的過程是誰的？你對它的詮釋讓它偏向 sublimity 還是 parody？Q6 的問題也可直接問：你在哪裡用了隨機？那裡是你沒想清楚，還是你要觀眾感到「意志之下的隨機」？
- 常見誤用：只引 Q8 的「過程是主要媒介」來否定使用現成工具；作者群自己在同一問題裡寫了反向的限制條件。

## 論點之間的對立

| 議題 | 一方 | 另一方 | 對創作者的意義 |
|---|---|---|---|
| 作者在哪一層 | Mohr：conceived and written by myself；Cohen：the program IS the rules，作者在規則與四十年的改寫 | Manovich 2019：架構、資料集、挑選三個控制點都算；Akten 2021：資料集策展（Ridler 等）也是高度控制 | 說明文字要寫對層：寫規則、選資料、挑輸出是三種不同的作者位置，都成立，但不能互相冒充 |
| 挑選算不算創作 | Akten 2021：curation 是 discrimination，不是 creation；Cohen 2010 的對話是改規則不是挑 | Duchamp 1957（見 01 章）：選擇即創作；Manovich 2019 把挑選列為控制點之一 | 如果作者工作主要是挑，就承認並讓挑選的標準成為作品可見的一部分 |
| 規則是不是內容 | McCormack et al. 2014 Q8：過程是主要媒介；Watz 2010：生成藝術關心封閉、自足的構造；Reas（見 02 章） | Manovich 2018：神經網路的規則是黑箱，看不見的規則無法當內容；Zylinska 2020：平台內的變化不是新 | 規則要能被說出來（Cohen 的亮度）才能當內容；說不出來時內容只能在使用方式或輸出 |
| 早期演算法藝術 vs AI 生成 | Nake 2010：可計算性與明寫規則是門檻；Bense：數值的、可操作的描述 | Manovich 2019：差別不在方法而在控制的量與類型，機器學習不比 1960 年代更「智慧」，反而限制更多 | 問自己用模型的理由：是要「人做不到的系統性」（Manovich 第三提案），還是只是省事 |
| 輸入換掉會不會一樣 | Ikeda test pattern：任何資料皆可，主題是系統與知覺；Akten *Learning to See*：吞掉輸入就是論點 | Crawford & Paglen：資料的分類有政治；Steyerl：資料是被綁架的平均 | 「輸入不重要」可以成立，但要寫明；「輸入很重要」就要能回答資料是誰的、怎麼分類的 |
| 隨機性 | Levin 2005：無限變化仍要感到必然；McCormack Q6：完全理解過程就不需要隨機 | Cage（見 02 章）：隨機用來去除自我；Xenakis：隨機是意志產物的必要部分 | 每一處隨機都要能回答「為什麼這裡」；回答不出來的隨機是沒想清楚的部分 |
| 「機器有沒有創造力」這個問題 | McCormack Q1 認真問；Boden 三型提供可檢驗的分類 | Cohen 1999 從不宣稱；Zylinska 2020 稱之為誤導性的問題 | 對創作者有用的是 Boden 的「哪一型」與 Cohen 的「程式知道什麼」，不是是非題 |
| 美學同質化 | Steyerl 2023：收斂到平均；Zylinska：crowd-sourced beauty；Watz：演算法有材料偏向 | Manovich 2018：兩個方向的力量並存，應量測而非斷言 | 可直接檢查：你的輸出跟同工具其他使用者差多少、差在哪 |
| 大型資料視覺化 | Ikeda：純資料、數學精確、知覺門檻 | Zylinska 的 "platform art"、Steyerl 的 "hallucinated mediocrity"（Anadol 的 Saltz／Davis 評論原文未取得，見缺口） | 資料「很美」不是主題；主題要落在系統、知覺或資料政治三者之一 |

## 可以問學生的問題

1. 把你的系統分成「架構／規則」「訓練資料或輸入」「參數」「挑選」四層，每層各寫一句你做了什麼決定。哪一層是空的？
2. 如果把輸入換成任意別的影片或資料集，作品會變成另一件嗎？你希望答案是哪一個？現在的作品符合你希望的答案嗎？
3. 你用的演算法或模型偏向產生什麼樣的結果（Watz 的「材料偏向」）？你的作品順著它還是對抗它？
4. 你的系統上一次產生讓你意外而且你決定保留的東西是什麼？保留的理由是什麼？
5. 你能向沒有技術背景的觀眾說出「這個系統知道什麼」嗎（Cohen 的提問方式）？如果只能說「它學了很多圖」，內容在哪裡？
6. 這件作品的每一個現場控制（感測器、MIDI、攝影機），你能說出它改變了輸出的哪個可感知面向嗎？說不出來的那些，與亂數有何差別？
7. 觀眾看到的每個變化，會覺得「只能是這樣」還是「換一個也可以」？你怎麼知道？
8. 你的作品在 Boden 三型裡屬於哪一型：組合、在別人定義的空間裡探索、還是改變了空間的規則？
9. 你知道你用的預訓練模型是用什麼資料集訓練的、那個資料集怎麼分類「人」嗎？不知道的話，這部分的作者是誰？
10. 你的作品與同一工具其他使用者的作品，差異在哪裡？觀眾能否不看說明就看出差異？
11. 如果你的作者工作主要是挑選，挑選的標準是什麼？這個標準有沒有在作品裡被看見？
12. 你用生成模型的理由是哪一個：人做不到的系統性、速度、風格、還是省事？說明文字寫的是哪一個？
13. 作品裡的隨機出現在哪裡？每一處你能回答「為什麼是這裡」嗎？
14. 你的資料來源涉及誰的勞動（標注、拍攝、上傳）？作品承認這些嗎，還是把它們當成「素材」？
15. 如果拿掉所有視覺輸入，你的系統還能產生什麼？那部分就是你寫進去的；它夠成為作品嗎？

## 本章缺口

- Vera Molnár：一手訪談與自述（如 *Leonardo* 1975 "Toward Aesthetic Guidelines for Paintings with the Aid of a Computer"）未取得——JSTOR 回錯誤頁、veramolnar.com SSL 錯誤、dam.org 憑證過期、monoskop 403；ZKM 與 Wikipedia 頁面無可引原文。本章未立條目，不以二手代替。
- Max Bense 原文（1965 德文、1971 英譯）未取得；僅經 Galanter 2016 所引一段與 Nake 2010 的轉述。
- Frieder Nake, "Information Aesthetics: An heroic experiment"（*Journal of Mathematics and the Arts*, 2012）付費牆，摘要亦未取得。
- Refik Anadol *Unsupervised*（MoMA 2022–23）的評論：Jerry Saltz（*Vulture*）與 Ben Davis（*Artnet News*）原文均無法開啟（站點封鎖、artnews.com 轉向付費代理）；Wikipedia 頁面無評論引文。本章只在核心問題與對立表提及，未引用任何評論句。
- Manfred Mohr 1971 巴黎目錄：僅見掃描縮圖與 21MB PDF 連結，文字未讀；emohr.com 其他自述頁只有導覽。
- Marius Watz 2010 "Closed Systems"：僅經 Scribd 頁面讀到部分段落；原始發表處文件內未標。
- Ryoji Ikeda 訪談未取得，僅用網站作品聲明；分析見 05 章 Lakatos 2020。
- Boden *The Creative Mind* 原書未讀，經 SEP 轉述。
- Casey Reas、Galanter 2003／2016、Boden & Edmonds 2009、Burnham 1968、Hertzmann 2018 本章不重複，見 02 章。
