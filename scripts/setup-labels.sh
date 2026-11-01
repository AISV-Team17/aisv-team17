#!/usr/bin/env bash
# GitHub 라벨 일괄 생성 스크립트
# 사용법: bash scripts/setup-labels.sh

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

# priority
create_label "priority: urgent" "b60205" "지금 처리 안 하면 다른 작업이 막힘"
create_label "priority: high"   "e99695" "MVP 핵심 기능 또는 일정에 직접 영향"
create_label "priority: medium" "f9d0c4" "일반 기능 구현, 개선"
create_label "priority: low"    "fef2c0" "후순위 정리, 문서"

# size
create_label "size: L"  "c2e0c6" "2일 이상"
create_label "size: M"  "c2e0c6" "하루 내외"
create_label "size: S"  "c2e0c6" "반나절 이내"
create_label "size: XS" "c2e0c6" "30분 이내"

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