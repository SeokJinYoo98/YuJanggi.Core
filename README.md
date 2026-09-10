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

## 자동 배포

개발과 PR 검증은 dev에서 진행하고 **main push 또는 PR 병합 시 자동 배포**합니다. 수동 태그 push는 배포를 시작하지 않습니다.

버전 기준은 package.json의 version (현재 0.1.0)입니다. 새 패키지가 필요하면 dev에서 MAJOR.MINOR.PATCH 버전을 올리고 main에 병합하세요. 이미 완료된 버전은 건너뜁니다.

자동 순서: 버전 확인 → 테스트·패키지 생성 → 소스 태그 v버전 및 draft Release 생성 → NuGet 게시 → 첨부 파일 업로드 → Release 공개.
실패하면 draft 상태로 남으며 원래 커밋의 Actions 실행을 재실행합니다. 미완료 버전을 다른 커밋으로 재사용하면 중단합니다. 기존 버전 태그는 이동하지 않습니다.

GitHub Actions가 허용되어야 하며 GITHUB_TOKEN에 선언한 contents:write와 packages:write를 조직 정책이 허용해야 합니다. NuGet 소비 CI에는 패키지 읽기 권한을 부여하고 개발 PC의 PAT classic(read:packages)은 커밋하지 않습니다.

- NuGet 소스: https://nuget.pkg.github.com/SeokJinYoo98/index.json
- NuGet 패키지: YuJanggi.Core
- Unity Git URL: https://github.com/SeokJinYoo98/YuJanggi.Core.git#v0.1.0 (실제 게시된 버전으로 변경)
- Release의 .tgz는 Unity Package Manager에서 tarball로 설치할 수 있습니다.

Unity에는 기존 소스 UPM을 사용하며 Core DLL을 중복 추가하지 않습니다.
서버·Unity의 참조 버전과 잠금 파일은 별도 변경으로 함께 검증합니다. 패키지 게시가 운영 서버나 게임 업데이트를 의미하지 않습니다.

로컬 검증: `./scripts~/Build-Packages.ps1`. 같은 출력 폴더가 있으면 깨끗한 체크아웃에서 검증합니다. 로컬 생성 검증은 실제 GitHub 게시나 Unity Player 검증을 대신하지 않습니다.

## 현재 호환 정보

- 패키지: **0.1.0**

- Unity 메타데이터: **6000.3**

- .NET: **10.0**, Nullable 활성화
