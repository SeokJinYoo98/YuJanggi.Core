# YuJanggi.Core

Unity와 .NET 서버가 공유하는 C# 장기 규칙 엔진입니다.

클라이언트와 서버에서 규칙을 중복 구현하지 않도록, UnityEngine에 의존하지 않는 라이브러리로 분리했습니다.

[Unity](https://github.com/SeokJinYoo98/YuJanggi.Unity) / [Server](https://github.com/SeokJinYoo98/YuJanggi.Server) / [포트폴리오](https://app.notion.com/p/3b48a299d1c481fe8347fabb240b814e)

## 설계에서 집중한 점

- **규칙과 화면 분리:** 입력과 화면이 달라도 같은 이동 판정을 사용하도록 공용 Core를 구성했습니다.

- **이동 전 검증:** 턴, 소유권, 합법성을 확인한 뒤 보드와 기보를 갱신합니다. 실제 이동 요청은 MatchModel에서 처리합니다.

- **이동과 복원:** 이동 기록에 포획 정보를 남겨 무르기에서 기물과 점수를 복원합니다. 합법 수 계산에도 임시 이동과 Undo를 사용합니다.

- **상태 보존 테스트:** 잘못된 요청 이후 상태 유지, 포획 후 Undo, 한 수 쉼을 자동화 테스트로 확인하도록 구성했습니다.

## 주요 기능

9 × 10 보드, 기물별 이동과 궁성 규칙, 장군 판정, 턴, 점수, 기보, 한 수 쉼과 기권을 지원합니다.

## 연결

**Unity**

Git UPM으로 아래 URL을 추가합니다.
COMMIT_SHA는 검증한 커밋으로 바꿉니다.

```text
https://github.com/SeokJinYoo98/YuJanggi.Core.git#COMMIT_SHA
```

**Server**

Core 저장소를 submodule로 두고 YuJanggi.Core.csproj를 ProjectReference로 참조합니다.

Unity와 Server의 Core 참조 커밋은 함께 맞춰야 합니다.

## 사용 예시

```csharp
using Yujanggi.Core.Board;
using Yujanggi.Core.Domain;
using Yujanggi.Core.Match;
using Yujanggi.Core.Rule;

var match = new MatchModel(
    new Turn(0), new Record(), new Score(),
    new BoardModel(), new JanggiRule());

match.InitGame(Formation.EHHE, Formation.EHHE);
match.BindEvents();
match.StartGame();

// 초의 졸을 한 칸 전진
bool moved = match.TryMove(new Pos(0, 3), new Pos(0, 4));

// 사용 종료 시 이벤트 연결 해제
match.UnBindEvents();
```

TryMove()가 턴, 소유권, 합법성을 검증한 뒤 이동을 적용합니다.

## 테스트

```powershell
dotnet test .\Tests~\YuJanggi.Core.Tests.csproj
```

MSTest **19개 메서드, 20개 케이스**로 이동 규칙, 상태 보존, Undo, 한 수 쉼을 검증합니다.

## 사용 시 참고

- 대국 상태 변경은 MatchModel을 사용하세요. 하위 모델의 변경 API도 공개되어 있어 우회 호출은 막지 않습니다.

- 합법 수 계산의 임시 이동은 정상 실행 시 복구됩니다. 예외 발생 시 복구는 보장되지 않습니다.

## 호환 정보

- 패키지: **0.1.0**

- Unity 메타데이터: **6000.3**

- .NET: **10.0**, Nullable 활성화
