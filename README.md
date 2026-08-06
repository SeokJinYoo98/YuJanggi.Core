# YuJanggi.Core

Unity 클라이언트와 .NET 서버가 함께 사용하는 장기 규칙 및 대국 상태 라이브러리입니다.

## 구성

| 경로 | 역할 |
| --- | --- |
| `Runtime` | 보드, 기물, 이동 규칙, 턴, 점수, 기보, 대국 상태 |
| `Tests~` | MSTest 기반 규칙 및 상태 회귀 테스트 |
| `YuJanggi.Core.csproj` | .NET 10 클래스 라이브러리 |
| `package.json` | Unity Git UPM 패키지 |

Core는 `UnityEngine`에 의존하지 않습니다. Unity에서는 Git UPM 패키지로, .NET에서는 프로젝트 참조로 같은 소스를 사용합니다.

## Unity에서 사용

`Packages/manifest.json`에 사용할 커밋 SHA를 고정해 추가합니다.

```json
"com.seokjinyoo.yujanggi.core": "https://github.com/SeokJinYoo98/YuJanggi.Core.git#COMMIT_SHA"
```

## .NET에서 사용

저장소를 submodule로 추가한 뒤 프로젝트를 참조합니다.

```xml
<ProjectReference Include="..\Core\YuJanggi.Core.csproj" />
```

## 검증

```powershell
dotnet test .\Tests~\YuJanggi.Core.Tests.csproj
```
