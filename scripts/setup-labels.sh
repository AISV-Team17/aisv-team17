#!/usr/bin/env bash
set -e

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "🏷  라벨 생성: $REPO"

create_label() {
  local name="$1" color="$2" desc="$3"
  gh label create "$name" --color "$color" --description "$desc" --repo "$REPO" --force
}

# type
create_label "feat"     "0075ca" "새로운 기능"
create_label "fix"      "d73a4a" "버그 수정"
create_label "refactor" "e4e669" "코드 개선 (기능 변경 없음)"
create_label "perf"     "f9a825" "성능·품질·지표 개선"
create_label "test"     "0e8a16" "테스트 코드"
create_label "docs"     "0075ca" "문서 수정"
create_label "chore"    "ededed" "설정, 빌드, 기타"
create_label "style"    "fef2c0" "포맷팅"
create_label "hotfix"   "b60205" "긴급 수정"

# area
create_label "area: backend"  "bfd4f2" "backend/"
create_label "area: model"    "bfd4f2" "model/"
create_label "area: frontend" "bfd4f2" "frontend/"
create_label "area: infra"    "bfd4f2" "infra/"
create_label "area: docs"     "bfd4f2" "docs/"

# status / action
create_label "blocked" "b60205" "선행 작업 대기 중"
create_label "eval"    "5319e7" "모델 평가 워크플로우 실행"

echo "✅ 라벨 생성 완료"