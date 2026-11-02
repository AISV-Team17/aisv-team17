# ADR-020: CD 배포는 GitHub Actions + SSH Deploy Key로 Vultr 서버에 직접 접속한다

| 항목 | 값 |
| --- | --- |
| **상태** | 수락됨 |
| **날짜** | 2026-10-31 |
| **작성자** | `AI-SVC` |
| **검토자** | `AI-MDL` |

---

## 컨텍스트

인프라가 Vultr로 결정됨에 따라(ADR-014) AWS OIDC 방식은 사용 불가하다. Vultr는 AI/ML 특화 서비스가 없는 순수 IaaS로, AWS IAM이나 OIDC 공급자와 같은 자격 증명 연동 체계를 제공하지 않는다. GitHub Actions에서 Vultr 서버에 접근할 인증 수단을 결정해야 한다.

## 결정 근거

- 설정·관리 복잡도.
- 키 유출 시 피해 범위와 회수 속도.
- 클라우드 종속성.

## 고려한 옵션들

- 옵션 1: 비밀번호 기반 SSH (서버에 팀원 비밀번호 설정)
- 옵션 2: SSH Deploy Key — 전용 키 쌍을 생성해 공개키를 서버에, 개인키를 GitHub Secrets에 보관
- 옵션 3: Vultr API Key로 직접 배포 스크립트 작성

## 결정

옵션 2 **SSH Deploy Key**를 선택한다. GitHub Actions 공식 지원 방식이고(`appleboy/ssh-action`), 설정이 단순하며 클라우드 종속성이 없다. 개인키는 GitHub Secrets에만 존재하고 서버에는 공개키만 올라가 비밀번호 방식보다 탈취 위험이 낮다. Vultr API Key(옵션 3)는 서버 접근 외에 과금·삭제 권한까지 포함돼 범위가 과도하다.

## 결과

**긍정적**

- GitHub Secrets에만 개인키가 존재하고 서버에는 공개키만 등록된다.
- 클라우드 종속 자격 증명 체계 없이 표준 SSH로 동작한다.
- 키 교체가 필요하면 Secrets 1개만 갱신하면 된다.

**부정적**

- Deploy Key가 유출되면 서버에 직접 접근 가능하므로 키 생성 시 passphrase 없이 만들어야 하는 구조적 한계가 있다.
- OIDC처럼 토큰 수명 제한이 없어 유출 시 즉시 교체해야 한다.

**후속 작업**

- ed25519 키 쌍 생성 후 공개키를 서버 `~/.ssh/authorized_keys`에 등록, 개인키를 `DEPLOY_SSH_KEY` Secret에 저장 (T1-16)
- cd.yml에 `appleboy/ssh-action` 스텝 추가 — docker compose pull → up -d 순서로 실행
- Vultr Cloud Firewall에서 SSH(22) 인그레스를 팀원 IP로 제한

---

## 옵션별 장단점

### 옵션 1 — 비밀번호 SSH

- 장점: 설정이 가장 단순하다.
- 단점: 비밀번호가 Secrets에 평문으로 들어가고 brute-force 위험이 있다.

### 옵션 2 — SSH Deploy Key (채택)

- 장점: 키 기반 인증으로 비밀번호 없이 안전하고, GitHub 공식 액션으로 설정이 표준화된다.
- 단점: 키 유출 시 수명 제한이 없어 즉시 교체해야 한다.

### 옵션 3 — Vultr API Key

- 장점: API로 서버 제어까지 가능하다.
- 단점: 권한 범위가 서버 생성·삭제·과금까지 포함돼 배포 전용으로 쓰기에 위험하다.

## 연관 ADR

- Related to ADR-019, ADR-021
- Refines ADR-014

## 참조

- appleboy/ssh-action GitHub Actions
- Vultr Cloud Firewall 문서

---

end.