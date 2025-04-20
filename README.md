#  전자기기 쇼핑몰 MSA 프로젝트

> 마이크로서비스 아키텍처(MSA) 기반의 전자상거래 백엔드 시스템  
> 실무 수준의 인증, 배포, 성능 개선, 장애 대응까지 고려한 인프라 중심 프로젝트

---
## 레파지토리 링크 
- [MALL_PRODUCT](https://github.com/ImHyukJin/mall-product-service) // [MALL_ORDER](https://github.com/ImHyukJin/mall-order-service) //  [MALL_CART](https://github.com/ImHyukJin/mall-cart-service) //  [MALL_ADMIN]()  //   [MALL_USER]()

---
##  목차

- [프로젝트 소개](#프로젝트-소개)
- [기술 스택](#기술-스택)
- [시스템 아키텍처](#시스템-아키텍처)
- [서비스 구성](#서비스-구성)
- [ERD (Entity-Relationship Diagram)](#erd-entity-relationship-diagram)
- [주요 기능 및 기여](#주요-기능-및-기여)


---

##  프로젝트 소개

전자기기 쇼핑몰 백엔드 시스템을 MSA 기반으로 설계 및 구현하였습니다.  
각 도메인 서비스(Product, Order, Cart 등)를 독립적으로 분리하고, JWT 인증을 Nginx + Lua로 위임하여 서비스의 인증 책임을 제거하였습니다.  
CI/CD 자동화, Redis 캐싱, 무중단 배포, 로깅 및 장애 추적까지 **실무 수준의 인프라 환경을 구축**한 프로젝트입니다.

-  **진행 기간**: 2025.03 ~ 2025.04 (진행 중)
-  **개발 형태**: 팀 프로젝트 (BE 2명, FE 1명)
-  **역할**: 전체 백엔드 아키텍처 설계, 주요 서비스 구현, CI/CD 자동화, 인증 게이트웨이 구현

---

## 기술 스택

| 분류        | 기술 |
|-------------|------|
| Backend     | Java 11, Spring Boot, Spring Data JPA, MyBatis |
| Infra/DevOps| Docker, Docker Compose, Nginx, GitHub Actions, Redis |
| 인증/보안   | JWT, Nginx + Lua, Spring Security |
| DB          | MySQL, Redis |
| 배포        | AWS EC2, Docker Hub |
| 기타        | REST API, Blue-Green 배포, Trace-ID 기반 로깅 |

---

##  시스템 아키텍처

- 각 서비스(Product, Order, Cart, User, Admin 등)는 완전 독립 구성 (MSA)
- 서비스 간 통신은 REST API, 인증은 JWT 기반으로 처리
- **Nginx + Lua**를 통해 JWT 검증 → 서비스 인증 책임 제거
- **Redis 캐시**를 도입해 장바구니 성능 최적화
- **Docker Compose**로 개발 환경 구축, **GitHub Actions**로 배포 자동화
- **Blue-Green 배포 전략**으로 무중단 배포 지원
- **Trace-ID 기반 로깅**으로 장애 추적 가능
  
<img src="https://github.com/user-attachments/assets/dc8ad580-2307-4a42-b9fd-4829b5464ca7" width="500" height= "350">
---

##  서비스 구성

###  mall_product
- **기능**
  - 상품 CRUD (등록, 수정, 삭제)
  - 상품 검색 및 상세 조회
  - 이미지 URL 등록 및 관리



###  mall_order
- **기능**
  - 주문 생성 / 조회 / 취소
  - 주문 시 재고 차감 처리
  - 외부 결제 API 연동 (결제 요청 처리)



###  mall_cart
- **기능**
  - 장바구니 담기 / 수정 / 삭제
  - 사용자별 장바구니 개별 관리



###  mall_user
- **기능**
  - 회원가입 및 로그인
  - JWT 기반 인증 및 검증
  - OAuth2 로그인, SMS 인증 기능 제공



###  mall_admin
- **기능**
  - 관리자용 상품 관리 기능
  - 사용자 관리 및 통계 데이터 제공



###  mall_infra
- **기능**
  - **Nginx 설정**: Reverse Proxy, JWT 인증(Lua Script 사용)
  - **Docker Compose**: 전체 MSA 서비스 오케스트레이션
  - **Redis, AWS RDS 연결 설정**
  - **CI/CD 자동화**:
    - GitHub Actions 기반 워크플로우 구성
    - Blue-Green 배포 전략 적용
  - 기타 공통 설정 파일 및 보안 설정 관리

---

## ERD (Entity-Relationship Diagram)
<img src="https://github.com/user-attachments/assets/0e2844f6-25ff-4eb8-9972-14bb1126f9e4" width="500" height= "350">

##  주요 기능 및 기여

### ✅ MSA 아키텍처 설계 및 구축
- 도메인 단위 서비스(Product, Order, Cart, User, Admin)를 분리하여 **독립적 배포 및 확장 가능한 구조** 설계
- 서비스 간 REST API 통신 기반, 인증은 JWT로 Stateless 처리
- 장애 발생 시 전체 서비스가 아닌 **개별 서비스만 격리되도록 설계**
- **Trace-ID 기반 로깅** 도입으로 서비스 간 연동 추적 가능

### ✅ 인증 게이트웨이 구현 (Nginx + Lua)
- 인증/인가를 서비스 내부가 아닌 **Nginx에서 전담**하도록 분리
- Lua 스크립트를 활용하여 JWT를 헤더에서 검증, 만료 여부 확인, 권한 판단 수행
- **서비스 내부 인증 책임 제거**, 인증 집중 관리로 보안성 및 유지보수성 향상

### ✅ CI/CD 자동화 및 무중단 배포
- GitHub Actions를 통한 **Test → Build → Docker Hub 푸시 → EC2 배포** 파이프라인 구성
- **배포 시간 약 90% 단축 (10분 → 1분)**
- Blue-Green 배포 전략으로 **무중단 배포 실현**
- 스크립트 기반 Nginx 및 Docker 이미지 구성으로 반복 작업 자동화

### ✅ Redis 기반 장바구니 캐시 처리
- Cart API에 Redis 도입으로 DB 호출 약 **35% 감소**
- **API 응답 속도 300ms → 70ms 수준으로 개선**
- 캐시 유효성 및 보존성을 고려한 Redis Persistence 구성

### ✅ 트래픽 대응 및 성능 최적화
- Nginx 로드밸런서를 통해 트래픽 분산 및 서비스 안정화
- 각 서비스 성격에 맞는 자원 분배 및 캐시 전략 구성
- Trace-ID 로깅, 예외 핸들링 전략, 로깅 표준화 등 **운영 중심 설계**

### ✅ 트러블슈팅 및 장애 대응
- 환경 변수 누락 → `.env`, GitHub Secrets 통합 관리
- Redis 데이터 유실 → Redis Persistence, 백업 주기 설정
- JWT 만료 오류 → Lua 스크립트에서 만료 시 적절한 예외 반환
- 서비스 장애 추적 어려움 → **공통 Trace-ID 도입 + 로그 포맷 통일**

