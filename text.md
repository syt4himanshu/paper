A Literature Survey on Hybrid Blockchain-IoT Architectures for 
Transparent and Accountable Public Distribution Systems 
Jueli Chintawar, Vishwesh Patil, Vansh Barde, Himanshu Mire — Students, Computer Engineering Department, St. Vincent 
Pallotti College of Engineering & Technology (SVPCET), Nagpur, India. 
Dr. Kapil Gupta — Associate Professor, Computer Engineering Department, SVPCET, Nagpur, India. 
Abstract— India's Public Distribution System (PDS) delivers 
subsidized food grain to more than 800 million people through 
nearly 500,000 Fair Price Shops. Even after digital reforms such 
as Aadhaar seeding, electronic Point-of-Sale (ePoS) devices, and 
the One Nation One Ration Card (ONORC) scheme, the system 
still struggles with leakage, diversion, authentication failures, 
stock manipulation, and a lack of real-time oversight — 
problems that stem from how the system is architected rather 
than simply from too little digitization. Centralized relational 
databases 
handle 
transactions 
efficiently, 
but 
because 
authorized staff can still edit them after the fact, they cannot 
provide records that are tamper-evident or independently 
verifiable. This survey reviews forty-eight studies across fifteen 
technology areas relevant to transparent welfare delivery — 
blockchain ledgers, food supply-chain traceability, IoT-based 
physical verification, digital governance, biometric and token 
authentication, 
hash 
chaining, 
smart 
contracts, 
hybrid 
blockchain-cloud architectures, AI-based fraud detection, 
digital wallets, role-based access control, and cloud-hosted 
government computing. Each of these technologies has been 
validated individually, but none of the surveyed work — 
including the closest hybrid blockchain-cloud proposals — 
combines more than two or three of them into one working 
architecture. This gap is what motivates the proposed Digital 
Supervision Layer, which brings together hybrid blockchain 
anchoring, IoT-based quantity verification, layered multi-factor 
authentication, blockchain-aware role-based access control, an 
auditable digital wallet, and real-time anomaly detection within 
a single transaction pipeline. 
Keywords— blockchain, Internet of Things, public distribution 
system, hash-linked ledger, anomaly detection, role-based access 
control, multi-factor authentication, digital wallet 
I. INTRODUCTION 
A. Background and the Digitalization Gap 
India distributes subsidized rice, wheat, sugar, and kerosene 
through roughly half a million Fair Price Shops (FPS), run jointly 
by state civil supply departments and the Food Corporation of 
India (FCI) [1]. The system began on paper ration cards and 
manual stock registers, and it stayed most opaque exactly where 
diversion is easiest — at warehouse dispatch, in transport, and 
at the shop counter [14]. When the National Food Security Act 
(NFSA) of 2013 turned entitlements into a legal right for roughly 
two-thirds of the population, it multiplied the audit burden on 
infrastructure that was never built for that scale [1, 3]. 
Later digitization efforts — End-to-End Computerisation, 
Aadhaar seeding, ePoS devices, and ONORC portability — 
responded to the fact that manual records simply could not be 
reconciled against real allocations in anything close to real time 
[13, 16]. But ePoS rollout only strengthened point-of-sale 
authentication; it never produced a verifiable, tamper-evident 
record running from godown to household, because ePoS logs 
sit in siloed state servers that departments themselves can still 
edit [14]. That gap between "digitized" and "trustworthy" is 
what draws attention to cryptographically verifiable, IoT-
instrumented PDS architectures — the subject of this survey. 
B. Persisting Structural Weaknesses 
Two decades of computerization have not resolved several core 
problems. Grain still leaks between warehouse and shop despite 
ePoS adoption [3]. Diversion still happens, since transaction 
records remain editable during or after entry, so grain can be 
logged as distributed while it is actually redirected to the open 
market 
[5]. 
Authentication 
still 
fails 
in 
ways 
that 
disproportionately deny entitlements to elderly beneficiaries 
and manual laborers, largely because of biometric mismatches 
[18]. Stock manipulation persists because systems record what 
a 
transaction 
claims 
happened 
without 
independently 
confirming what was actually dispensed [12]. Transparency 
remains weak, since beneficiaries have no way to verify that 
centralized records have not been altered [21]. And real-time 
monitoring is still largely absent, as state platforms rely on 
periodic batch uploads rather than continuous reporting [15]. 
C. Motivation and Scope 
These failures look operationally distinct, but they share one 
root cause: existing systems record transactions without 
guaranteeing that those records cannot be quietly changed 
afterward. Blockchain anchoring, hash chaining, and IoT-based 
physical verification exist specifically to close that gap. Rather 
than replacing the existing PERN/PostgreSQL operational stack, 
this survey's goal is to strengthen it with a hybrid blockchain-
based supervision layer — adding cryptographic integrity and 
non-repudiation only where fraud is most likely, while 
preserving the scalability of a conventional relational database 
everywhere else. 
Fifteen technology areas are covered: blockchain in PDS and 
food supply chains; IoT-based smart ration hardware; digital 
governance; Aadhaar and QR-based authentication; hash 
chains; Ethereum smart contracts; hybrid blockchain-cloud 
architecture; AI/ML fraud detection; digital wallets; supply-
chain transparency; role-based access control (RBAC); and 
cloud-based government computing. Priority was given to work 
from 2020–2025, supplemented by foundational papers where 
needed. Papers focused purely on agricultural procurement or 
yield forecasting were excluded, since they sit outside the 
distribution-and-audit scope this survey addresses. 
II. LITERATURE SURVEY 
A. Blockchain in Public Distribution Systems 
Research on bringing blockchain and IoT into India's PDS 
consistently points to centralized record management as a 
major driver of short weighing, stock diversion, and the absence 
of trustworthy audit trails — though the studies reviewed here 
differ a lot in how far they actually got. Malathi et al. [4] built a 
permissioned Ethereum blockchain across Raspberry Pi nodes 
using Proof-of-Authority instead of Proof-of-Work, pairing QR-
code ration authentication with a Tamil voice/text interface on 
a NodeJS/Web3 stack to make the system more usable for rural 
residents with limited literacy. A ten-day field trial with 80 
participants in Anjur village reported full transaction 
immutability, response latency around 130 ms, block-
generation delays of 100–250 ms, and 90% user satisfaction — 
real evidence that blockchain and IoT can run on modest 
hardware. But that feasibility was only demonstrated at village 
scale: throughput drops off past roughly 40 requests per second 
because of the fixed block size, and per-transaction delay grows 
with every added node, leaving national or multi-state 
performance an open question. Shwetha and Prabodh [5] and 
Singh et al. [6] stay at the conceptual level instead, and between 
them expose two complementary gaps: the former sketches IoT-
logged commodity tracking on a blockchain ledger but, as a 
short conference paper, reports no throughput, latency, or 
deployment-cost figures and says nothing about consensus 
design or beneficiary-side authentication; the latter tackles the 
fragmentation between government agencies, warehouses, and 
shop owners with a consortium (permissioned) blockchain that 
splits data explicitly between on-chain and off-chain storage — 
anticipating the architectural pattern later needed at national 
scale — but never builds a prototype or runs a quantitative 
evaluation. Taken together, these three papers trace an arc from 
small-scale empirical proof to conceptual, unvalidated 
proposals. They establish that blockchain-IoT audit trails are 
worth pursuing, but leave open how such trails would scale 
nationally or connect to AI-based fraud detection. None of the 
three pairs ledger anchoring with real-time IoT quantity 
verification or AI-based anomaly detection — gaps the 
proposed Digital Supervision Layer closes by anchoring only 
transaction hashes on Ethereum Sepolia while keeping 
beneficiary data in PostgreSQL, replacing ad hoc QR-checkpoint 
tracking with load-cell/HX711 weight verification, and adding a 
streaming anomaly-detection module that none of the three 
provide. 
B. Blockchain for Food Supply Chains 
Early attempts at tamper-evident traceability in agri-food 
supply chains settled on pairing blockchain's immutable ledger 
with automatic data-capture technology. Tian's 2016 design-
stage proposal [7] weighs RFID against blockchain and 
combines them into a layered design for identifying, tracking, 
and tracing goods through production, warehousing, and sale. 
Its real contribution is framing the problem — showing that 
whole-chain, multi-stakeholder trust needs both reliable per-
node sensing and a shared tamper-resistant record — rather 
than empirical validation; it has no working implementation, no 
throughput evaluation, and no real treatment of RFID cost or 
blockchain scalability. Pincheira Caro et al.'s AgriBlockIoT [8] 
goes further, integrating IoT devices with blockchain smart 
contracts and benchmarking latency, CPU utilization, and 
network overhead across both Ethereum and Hyperledger 
Sawtooth in a farm-to-fork scenario. That gives useful insight 
into the trade-offs between permissioned and public chains, 
though the validation stays confined to a controlled testbed, and 
since the framework targets commercial traceability, it does not 
consider 
beneficiary 
authentication 
or 
entitlement 
management. Prashar et al. [9] focus specifically on the Indian 
agricultural ecosystem, pairing smart contracts with IPFS-based 
decentralized storage, and report the strongest quantitative 
performance of the three — 161 transactions per second with 
4.82-second convergence. Even so, like [7, 8], it addresses 
general market traceability rather than ration-card entitlement 
verification, skips IoT-based quantity sensing, and leaves 
governance and permissioning models unspecified. Together, 
[7–9] show that blockchain-based traceability is sound in 
principle and workable in practice, but none of them extends 
into last-mile welfare distribution or brings in AI-driven 
anomaly detection — the gap this survey's proposed 
architecture targets by anchoring PDS transaction hashes on 
Ethereum Sepolia while adding IoT weight verification and AI-
based anomaly detection that none of the three precedents 
offer. 
C. IoT-based Smart Ration Distribution 
A good deal of research has focused on modernizing Fair Price 
Shop operations by replacing manual ration distribution with 
embedded systems that can automate beneficiary verification 
and dispensing. Shukla et al. [10] proposed one of the earliest 
such systems, giving every beneficiary a unique RFID tag 
checked at a microcontroller-based reader against a backend 
database before releasing the monthly ration and updating 
consumption records in real time. It cut down on duplicate and 
fake ration cards effectively, but the implementation stayed a 
lab-scale prototype that never addresses unreliable rural 
connectivity, RFID tag cloning, or — more importantly — 
whether the quantity of grain actually dispensed matches what 
the database records. Gaikwad and Nikumbh [11] pursued a 
similar goal with smart cards and GSM communication, where a 
GSM module authenticates beneficiaries and sends an SMS 
confirming the transaction — a meaningful boost to beneficiary 
awareness, though the system inherits all the fragility of cellular 
coverage in remote areas and, like [10], stores no biometric 
binding, leaving the card vulnerable to loss or duplication. 
Indirani et al. [12] moved this forward by dropping the physical 
card altogether in favor of Aadhaar-linked fingerprint 
authentication paired with an STM32-controlled automated 
dispensing mechanism and OTP verification over GSM, logging 
transactions to a cloud-hosted spreadsheet. The biometric 
binding directly fixes the impersonation weaknesses in [10, 11], 
and sensor-controlled dispensing improves weighing precision 
over manual scooping — but using a spreadsheet as the system 
of record is actually a step backward for integrity, offering none 
of the access-control granularity or tamper-evidence a state-
scale deployment would need. Read together, these three works 
trace a clear progression — from RFID identity replacement, to 
GSM-mediated notification, to biometric authentication with 
automated dispensing — each incrementally strengthening 
beneficiary identification and shop-counter automation. Yet all 
three share the same blind spot: none verifies dispensed weight 
against entitlement in a way that is independently auditable, 
and none anchors its records in a tamper-evident, multi-
stakeholder ledger. The proposed system replaces card- or 
biometric-only authentication with an ESP32/load-cell/HX711 
weighing subsystem that gates transaction confirmation on 
measured-versus-entitled weight tolerance, while avoiding the 
fragile centralized data stores of [10–12] through Ethereum-
anchored hashes and layered AI-based anomaly detection 
absent from all three prior systems. 
D. Digital Governance in Welfare Systems 
Beyond the technical architecture of digitized ration delivery, a 
substantial body of scholarship looks at how digital identity and 
algorithmic governance actually behave once deployed among 
India's poorest households. Nagaraj and Prakash [13] use a 
complexity-theory lens along with survey and interview data 
from roughly 1,600 below-poverty-line households across two 
states and four districts, and find that the centrally designed 
Aadhaar-enabled PDS (AePDS) is largely blind to the diversity of 
local social relationships. The result is authentication failures, 
connectivity gaps, and biometric mismatches — particularly 
among elderly beneficiaries or those doing manual labor — 
which push frontline actors toward self-adaptive coping 
behaviors that often end up hurting poorer households the 
most. The scale and theoretical grounding of this fieldwork lend 
it real credibility, though the work stops short of proposing an 
alternative architecture. Hundal and Chaudhuri [14] examine 
the same problem through the lens of digital exclusion across 
Andhra Pradesh and Karnataka, showing how a technology 
meant to improve transparency can unintentionally become a 
source of exclusion once biometric devices fail or connectivity 
drops. Because the work appeared in conference format, the 
discussion stays fairly brief and does not dig deeply into 
underlying causes. Chaudhuri's later ethnographic study [15] 
broadens the picture further, arguing that AePDS algorithms 
should be understood not just as computational tools but as 
socio-technical processes shaped by ongoing interactions 
among officials, infrastructure, documents, and beneficiaries — 
a framing that exposes the gap between algorithmic design 
intent and operational reality, even though its purely qualitative 
method gives no quantifiable measure of exclusion to 
benchmark against. Together, these three studies converge on a 
common diagnosis: rigid, centralized biometric verification is 
brittle under real-world social and infrastructural conditions, 
and existing AePDS deployments lack auditable, tamper-evident 
records of the human-algorithm interactions that ultimately 
determine welfare outcomes. The proposed Digital Supervision 
Layer addresses this by retaining the existing e-PoS/Aadhaar-
linked pathway rather than replacing it, while layering OTP- and 
QR-based time-bound authentication and blockchain-anchored 
hash trails on top of it — avoiding sole reliance on any single 
point-of-failure biometric check. 
E. Aadhaar Authentication 
Aadhaar-based biometric authentication has become the 
primary way PDS reduces duplicate beneficiaries and cuts down 
on diversion. Muralidharan, Niehaus, and Sukhtankar [16] offer 
the strongest empirical evidence, combining a large-scale 
randomized controlled trial with a natural experiment on the 
phased rollout of Aadhaar-Based Biometric Authentication 
(ABBA) across Jharkhand, where fingerprints or facial 
biometrics captured through ePoS devices are matched against 
the Aadhaar Central Identities Data Repository before a 
transaction goes through. They find that mandatory biometric 
authentication meaningfully cut leakage and corruption, but the 
study also surfaces a serious implementation problem: an 
estimated 
1.5–2 
million 
beneficiaries 
temporarily 
or 
permanently lost access to entitled food grains during the 
transition, not because the biometric technology itself was 
flawed, but because of seeding errors, weak grievance redressal, 
and no practical fallback procedure. Menon [18] finds similar 
effects in an exploratory field survey in Ranchi district, 
reporting that only around 52% of ration-card holders managed 
to complete a purchase during the observation period, with 
failures mostly traced to incomplete Aadhaar seeding and the 
absence of an offline exception-handling mechanism. Nagaraj 
and Prakash [17] extend the discussion through complexity 
theory, arguing that the existing architecture applies a one-size-
fits-all strategy that overlooks the diverse social and operational 
relationships between beneficiaries and dealers. None of the 
three studies actually offers a complete technical fix: [16] 
focuses on improving implementation protocols without 
proposing an alternative framework, [17] argues for context-
sensitive design without a practical architecture to match, and 
[18] documents failure patterns without an effective fallback 
mechanism. The proposed Digital Supervision Layer builds on 
the shared conclusion that biometric authentication remains 
valuable but should not be the sole gatekeeper — it 
complements existing Aadhaar/ePoS infrastructure with OTP 
authentication, time-bound QR-code tokens, and JWT-secured 
sessions, while AI-assisted anomaly detection keeps a human in 
the 
loop 
rather 
than 
fully 
automating 
irreversible 
authentication decisions. 
F. QR-based Authentication and Cryptographic Hash Chains 
Kao et al. [19] combine OTP's one-time validity with QR's 
information-carrying capacity for physical access control, but 
they assume reliable mobile connectivity that has not been 
tested in low-connectivity rural settings. Gangurde et al. [20] 
instead protect a reusable QR credential (a train ticket) with 
AES encryption, but leave duplicate-redemption control 
unaddressed because no ledger tracks prior validations. The 
proposed system binds each QR token's validation outcome to a 
blockchain-anchored hash together with the HX711 weight-
verification step, closing both gaps at once. 
Haber and Stornetta's foundational hash-chaining scheme [21] 
certifies document timestamps but relies on neither Byzantine 
fault-tolerant consensus nor an external anchor. Shekhtman and 
Waisbard's EngraveChain [22] moves this idea onto a 
permissioned ledger (Hyperledger Fabric) but leaves hybrid on-
chain/off-chain scaling unexplored. Koisser and Sadeghi [23] 
generalize hash chains into a per-device hash tree for IoT fleets, 
but in doing so reintroduce centralized trust through a third-
party root anchor. None of the three combines hash-linked 
anchoring with a hybrid public/off-chain architecture or 
domain-specific fraud detection — the proposed layer pairs the 
append-only hash-chain idea from [21] with periodic public 
Ethereum anchoring, giving auditors an external, independentl