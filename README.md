# hrdkdh-skill

업무 과정에서 만든 재사용 가능한 Codex 스킬을 모아 관리하는 저장소입니다.

각 스킬은 독립된 폴더에 있으며, 에이전트가 이름과 설명만으로 용도를 판단하고 필요한 지침만 단계적으로 읽을 수 있도록 구성합니다.

## Skill catalog

| Skill | 용도 | 호출 | 진입점 |
|---|---|---|---|
| Simple Slide Design | 무채색·타이포그래피 중심의 간결하고 가독성 높은 발표자료 설계 및 리디자인 | `$simple-slide-design` | [SKILL.md](simple-slide-design/SKILL.md) |
| posco-report-coach | 업무·경영진 보고서와 문서 이미지의 논리·구조·표현·디자인 검수, 개선 문안 및 시안 제시 | `$posco-report-coach` | [SKILL.md](posco-report-coach/SKILL.md) |
| Make P-Cloud Docker Image | 사내 Windows/WSL 환경에서 P-Cloud용 Linux amd64 Docker 이미지 빌드·검증·TAR 반출 및 장애 진단 | `$make-pcloud-docker-image` | [SKILL.md](make-pcloud-docker-image/SKILL.md) |

새 스킬을 추가할 때 이 표도 함께 업데이트합니다. 에이전트는 먼저 이 표에서 후보를 찾은 뒤 선택한 스킬의 `SKILL.md`를 읽습니다.

## Repository structure

```text
hrdkdh-skill/
|-- README.md
|-- simple-slide-design/
|   |-- SKILL.md
|   |-- agents/
|   |   `-- openai.yaml
|   `-- references/
|       `-- html-slide-patterns.md
|-- posco-report-coach/
    |-- SKILL.md
    |-- agents/
    |   `-- openai.yaml
    `-- references/
        |-- content-review.md
        |-- visual-review.md
        |-- image-preview.md
        |-- work-modes.md
        `-- source-map.md
`-- make-pcloud-docker-image/
    |-- SKILL.md
    |-- agents/
    |   `-- openai.yaml
    |-- references/
    |   |-- corporate-ca.md
    |   `-- wsl-recovery.md
    `-- scripts/
        `-- docker_preflight.ps1
```

일반적인 스킬 폴더는 다음 구조를 따릅니다.

```text
skill-name/
|-- SKILL.md          # 필수: 이름, 설명, 핵심 지침
|-- agents/           # 선택: UI 표시 정보와 호출 정책
|-- references/       # 선택: 필요할 때만 읽는 상세 지침
|-- scripts/          # 선택: 반복 작업을 위한 실행 도구
`-- assets/           # 선택: 결과물에 사용하는 템플릿과 리소스
```

## Guidance for agents

1. 루트의 Skill catalog에서 요청에 맞는 스킬을 찾습니다.
2. 선택한 폴더의 `SKILL.md`를 처음부터 끝까지 읽습니다.
3. `SKILL.md`가 특정 reference, script, asset을 지시할 때만 해당 리소스를 추가로 읽거나 실행합니다.
4. 상대 경로는 해당 스킬 폴더를 기준으로 해석합니다.
5. 사용자의 명시적 요구와 권한 범위가 스킬의 일반 지침보다 우선합니다.
6. 예시 데이터와 문구는 형식을 설명하기 위한 것이며 사용자 콘텐츠로 간주하지 않습니다.

스킬 탐색에서 가장 중요한 정보는 `SKILL.md`의 YAML frontmatter입니다.

```yaml
---
name: skill-name
description: What the skill does and when it should be used.
---
```

`description`에는 기능뿐 아니라 어떤 요청에서 사용해야 하는지까지 명확히 적습니다.

## Installation

필요한 스킬 폴더를 Codex 스킬 디렉터리로 복사합니다.

```powershell
Copy-Item -Recurse .\simple-slide-design "$env:USERPROFILE\.codex\skills\"
Copy-Item -Recurse .\posco-report-coach "$env:USERPROFILE\.codex\skills\"
Copy-Item -Recurse .\make-pcloud-docker-image "$env:USERPROFILE\.codex\skills\"
```

설치 후에는 다음과 같이 명시적으로 호출할 수 있습니다.

```text
$simple-slide-design 이 발표자료를 간결하고 읽기 쉽게 다시 설계해 주세요.
$posco-report-coach 첨부한 보고서를 검토하고 우선 수정사항, 근거 위치, 바로 쓸 개선 문안을 제시해 주세요.
$make-pcloud-docker-image 현재 앱을 P-Cloud용 linux/amd64 TAR 이미지로 빌드하고 검증해 주세요.
```

설명이 현재 요청과 명확히 일치하면 에이전트가 자동으로 선택할 수도 있습니다.

`posco-report-coach`는 한국어 지침으로 보고서 검수 외에도 빈칸 보고서 설계, 경영진용 1쪽 요약, 예상 질문·답변 준비, 주장별 근거 점검을 지원합니다. 개선 시안 이미지는 실행 환경의 이미지 생성 또는 렌더링 도구가 있을 때 제작하며, 도구가 없으면 문안과 배치 명세를 제공합니다. 교재 기반 원칙과 AI용 보완의 구분은 [출처 지도](posco-report-coach/references/source-map.md)에서 확인할 수 있습니다.

`make-pcloud-docker-image`는 Windows/WSL 기반 P-Cloud 이미지 제작에서 Docker 데몬과 BuildKit 사전점검, 사내 CA의 안전한 전달 또는 오프라인 의존성 준비, Rocky Linux 이미지 구성, 컨테이너 기동 확인, TAR 및 체크섬 산출을 다룹니다. WSL 제어 채널 장애와 단순 Dockerfile 오류를 구분하고, 장시간 빌드에는 제한형 relay/keepalive 복구를 적용하며, 실제 산출물 검증 전에는 완료로 판단하지 않습니다.

## Adding a skill

- 폴더 이름과 frontmatter의 `name`은 소문자 kebab-case로 통일합니다.
- 모든 스킬에는 `SKILL.md`와 구체적인 `description`이 있어야 합니다.
- 공통 핵심 지침만 `SKILL.md`에 두고, 형식별 상세 내용은 `references/`로 분리합니다.
- 반복 실행이 정확성을 높이는 경우에만 `scripts/`를 추가합니다.
- 비밀번호, 토큰, 사내 개인정보, 운영 데이터는 저장하지 않습니다.
- 새 스킬을 추가하거나 이름을 바꾸면 Skill catalog와 구조 예시를 갱신합니다.
- 커밋 전 frontmatter, 상대 링크, 예시 파일, 미완성 TODO를 확인합니다.

Codex의 `skill-creator`가 설치되어 있다면 다음 검증기를 사용할 수 있습니다.

```powershell
python -X utf8 `
  "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" `
  ".\skill-name"
```

