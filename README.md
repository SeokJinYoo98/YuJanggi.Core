<div align="center">

# YuJanggi.Core

**Unity 클라이언트와 .NET 서버가 공유하는 Unity 비의존 장기 규칙 엔진**

![Package](https://img.shields.io/badge/package-0.1.0-2ea44f)
![Unity](https://img.shields.io/badge/Unity-Git_UPM-000000?logo=unity&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-10.0-512BD4?logo=dotnet&logoColor=white)
![Tests](https://img.shields.io/badge/MSTest-20_cases-2563eb)

[Unity Client](https://github.com/SeokJinYoo98/YuJanggi.Unity) ·
[Game Server](https://github.com/SeokJinYoo98/YuJanggi.Server) ·
[Portfolio](https://app.notion.com/p/3b48a299d1c481fe8347fabb240b814e)

</div>

## 소개

YuJanggi.Core는 한국 장기의 보드, 기물 이동 규칙과 대국 상태를 한곳에서 관리하는 C# 라이브러리입니다.

<code>UnityEngine</code>, <code>MonoBehaviour</code>와 Unity 생명주기에 의존하지 않습니다. Unity에서는 Git UPM 패키지로, .NET 서버에서는 ProjectReference로 이 라이브러리를 참조합니다. 같은 규칙 버전을 사용하려면 두 프로젝트의 Core 참조 커밋을 일치시켜야 합니다.

> **핵심 목표**
>
> 입력 방식, 화면 표현과 네트워크 환경이 달라도 규칙 판정과 상태 변경의 결과는 하나의 Core에서 결정합니다.

## 제공 기능

| 영역 | 책임 |
| --- | --- |
| Board | 9 × 10 보드, 기물 조회, 이동·포획과 Undo |
| Movement | 차, 포, 마, 상, 궁·사, 졸·병의 이동 후보 계산 |
| Rule | 궁성 대각선, 장군 판정, 왕을 노출하는 수 제거, 합법 수 조회 |
| Match | 이동 검증과 실행, 턴, 점수, 기보, 한 수 쉼과 결과 상태 |
| Domain | 좌표, 기물, 진영, 포진, 선택과 이동 결과 모델 |
| Events | 이동, 장군, 턴, 점수, 기보와 게임 종료 이벤트 |

## 처리 흐름

~~~mermaid
flowchart LR
    RQ["Move Request"] --> MM["MatchModel.TryMove"]
    MM --> V["Validate board / turn / ownership"]
    V --> JR["JanggiRule"]
    JR --> MR["MovementRule"]
    JR --> PR["PalaceRule"]
    JR --> CR["Check safety"]
    CR --> EX["Execute move"]
    EX --> S["Board / Turn / Score / Record"]
    S --> EV["Match Events"]
~~~

대국 중 상태 변경은 <code>MatchModel</code>을 진입점으로 사용하도록 설계되어 있습니다. <code>TryMove()</code>는 요청을 검증한 뒤 <code>JanggiRule</code>로 합법성을 확인하고, 허용된 이동을 보드·턴·점수·기보에 반영합니다. 다만 <code>Board</code>, <code>Turn</code>, <code>Score</code>, <code>Record</code>의 변경 API도 공개되어 있어, 호출자가 직접 변경을 피해야 합니다.

합법 수 필터링은 임시 이동 후 <code>UndoMove()</code>로 보드를 복구합니다. 현재 <code>try/finally</code>로 보호되어 있지 않아, 임시 이동 이후 판정 중 예외가 발생하면 복구가 보장되지 않습니다.

## 저장소 구조

~~~text
Runtime
├── Board
│   ├── BoardModel.cs
│   └── CellData.cs
├── Domain
│   ├── Domain.cs
│   ├── MoveRecord.cs
│   └── Selection.cs
└── Match
    ├── Movement
    ├── Rule
    ├── MatchModel.cs
    ├── Record.cs
    ├── Score.cs
    └── Turn.cs

Tests~
├── JanggiRuleTests.cs
├── MatchModelTests.cs
└── JanggiTestBoard.cs
~~~

| 파일 | 용도 |
| --- | --- |
| <code>package.json</code> | Unity Git UPM 패키지 메타데이터 |
| <code>YuJanggi.Core.csproj</code> | .NET 10 클래스 라이브러리 |
| <code>Tests~/YuJanggi.Core.Tests.csproj</code> | MSTest 회귀 테스트 프로젝트 |

## 설치

### Unity Git UPM

Unity 프로젝트의 <code>Packages/manifest.json</code>에 검증한 커밋 SHA를 고정합니다.

~~~json
{
  "dependencies": {
    "com.seokjinyoo.yujanggi.core": "https://github.com/SeokJinYoo98/YuJanggi.Core.git#COMMIT_SHA"
  }
}
~~~

Unity의 패키지 커밋과 Server의 Core submodule 커밋은 각각 관리됩니다. Core를 갱신할 때 두 참조를 동일한 검증된 SHA로 맞춰야 하며, 한쪽을 변경해도 다른 쪽이 자동으로 갱신되지는 않습니다.

### .NET ProjectReference

저장소를 submodule로 추가합니다.

~~~powershell
git submodule add https://github.com/SeokJinYoo98/YuJanggi.Core.git Core
git submodule update --init --recursive
~~~

호스트 프로젝트에서 Core 프로젝트를 참조합니다.

~~~xml
<ItemGroup>
  <ProjectReference Include="..\Core\YuJanggi.Core.csproj" />
</ItemGroup>
~~~

## 기본 사용 예시

~~~csharp
using Yujanggi.Core.Board;
using Yujanggi.Core.Domain;
using Yujanggi.Core.Match;
using Yujanggi.Core.Rule;

var match = new MatchModel(
    new Turn(0),
    new Record(),
    new Score(),
    new BoardModel(),
    new JanggiRule()
);

match.InitGame(Formation.EHHE, Formation.EHHE);
match.BindEvents();
match.StartGame();

bool moved = match.TryMove(
    new Pos(0, 3),
    new Pos(0, 4)
);
~~~

시작 턴은 초이며, 위 예시는 초의 졸을 한 칸 전진시킵니다. 실제 애플리케이션에서는 입력을 좌표 기반 요청으로 변환하고, Core 이벤트를 View 또는 네트워크 응답으로 전달합니다.

## 테스트

~~~powershell
dotnet test .\Tests~\YuJanggi.Core.Tests.csproj
~~~

현재 테스트 코드는 일반 테스트 메서드 18개와 DataRow 2개를 가진 데이터 테스트 메서드 1개로 구성됩니다. 총 19개 테스트 메서드, 20개 실행 케이스입니다.

검증 범위:

- 차, 포, 마, 상의 이동 규칙
- 궁성 내부 이동과 대각선
- 장군 상태와 왕을 노출하는 이동 거부
- 정상 이동의 보드, 턴, 점수와 기보 변경
- 잘못된 이동 이후 상태 보존
- 상대 진영 기물 이동 거부
- 포획 이후 Undo와 점수 복원
- 한 수 쉼 기록과 턴 변경

## 설계 원칙

- Core는 <code>UnityEngine</code>을 참조하지 않습니다.
- View와 네트워크 계층은 Core의 공개 변경 API를 직접 호출하지 않고 <code>MatchModel</code>을 사용해야 합니다.
- 대국의 실제 이동은 <code>MatchModel.TryMove()</code>를 통해 검증해야 합니다.
- 규칙 계산 중 임시 이동은 정상 실행 시 복구됩니다. 예외 발생 시 복구 보장은 추가 구현이 필요합니다.
- Client와 Server는 검증된 동일 Core 커밋을 참조하도록 함께 관리해야 합니다.

## 호환 정보

| 항목 | 값 |
| --- | --- |
| Package version | 0.1.0 |
| Unity package metadata | Unity 6000.3 |
| .NET target | net10.0 |
| Nullable reference types | enabled |

## 사용하는 프로젝트

- [YuJanggi.Unity](https://github.com/SeokJinYoo98/YuJanggi.Unity): 입력과 Unity 화면 표현
- [YuJanggi.Server](https://github.com/SeokJinYoo98/YuJanggi.Server): 자동 매칭과 서버 권위형 이동 판정
