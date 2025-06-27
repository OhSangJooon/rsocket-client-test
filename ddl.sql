create table BATCH_JOB_EXECUTION_SEQ
(
    ID         bigint not null,
    UNIQUE_KEY char   not null,
    constraint UNIQUE_KEY_UN
        unique (UNIQUE_KEY)
);

create table BATCH_JOB_INSTANCE
(
    JOB_INSTANCE_ID bigint       not null
        primary key,
    VERSION         bigint       null,
    JOB_NAME        varchar(100) not null,
    JOB_KEY         varchar(32)  not null,
    constraint JOB_INST_UN
        unique (JOB_NAME, JOB_KEY)
);

create table BATCH_JOB_EXECUTION
(
    JOB_EXECUTION_ID bigint        not null
        primary key,
    VERSION          bigint        null,
    JOB_INSTANCE_ID  bigint        not null,
    CREATE_TIME      datetime(6)   not null,
    START_TIME       datetime(6)   null,
    END_TIME         datetime(6)   null,
    STATUS           varchar(10)   null,
    EXIT_CODE        varchar(2500) null,
    EXIT_MESSAGE     varchar(2500) null,
    LAST_UPDATED     datetime(6)   null,
    constraint JOB_INST_EXEC_FK
        foreign key (JOB_INSTANCE_ID) references BATCH_JOB_INSTANCE (JOB_INSTANCE_ID)
);

create table BATCH_JOB_EXECUTION_CONTEXT
(
    JOB_EXECUTION_ID   bigint        not null
        primary key,
    SHORT_CONTEXT      varchar(2500) not null,
    SERIALIZED_CONTEXT text          null,
    constraint JOB_EXEC_CTX_FK
        foreign key (JOB_EXECUTION_ID) references BATCH_JOB_EXECUTION (JOB_EXECUTION_ID)
);

create table BATCH_JOB_EXECUTION_PARAMS
(
    JOB_EXECUTION_ID bigint        not null,
    PARAMETER_NAME   varchar(100)  not null,
    PARAMETER_TYPE   varchar(100)  not null,
    PARAMETER_VALUE  varchar(2500) null,
    IDENTIFYING      char          not null,
    constraint JOB_EXEC_PARAMS_FK
        foreign key (JOB_EXECUTION_ID) references BATCH_JOB_EXECUTION (JOB_EXECUTION_ID)
);

create table BATCH_JOB_SEQ
(
    ID         bigint not null,
    UNIQUE_KEY char   not null,
    constraint UNIQUE_KEY_UN
        unique (UNIQUE_KEY)
);

create table BATCH_STEP_EXECUTION
(
    STEP_EXECUTION_ID  bigint        not null
        primary key,
    VERSION            bigint        not null,
    STEP_NAME          varchar(100)  not null,
    JOB_EXECUTION_ID   bigint        not null,
    CREATE_TIME        datetime(6)   not null,
    START_TIME         datetime(6)   null,
    END_TIME           datetime(6)   null,
    STATUS             varchar(10)   null,
    COMMIT_COUNT       bigint        null,
    READ_COUNT         bigint        null,
    FILTER_COUNT       bigint        null,
    WRITE_COUNT        bigint        null,
    READ_SKIP_COUNT    bigint        null,
    WRITE_SKIP_COUNT   bigint        null,
    PROCESS_SKIP_COUNT bigint        null,
    ROLLBACK_COUNT     bigint        null,
    EXIT_CODE          varchar(2500) null,
    EXIT_MESSAGE       varchar(2500) null,
    LAST_UPDATED       datetime(6)   null,
    constraint JOB_EXEC_STEP_FK
        foreign key (JOB_EXECUTION_ID) references BATCH_JOB_EXECUTION (JOB_EXECUTION_ID)
);

create table BATCH_STEP_EXECUTION_CONTEXT
(
    STEP_EXECUTION_ID  bigint        not null
        primary key,
    SHORT_CONTEXT      varchar(2500) not null,
    SERIALIZED_CONTEXT text          null,
    constraint STEP_EXEC_CTX_FK
        foreign key (STEP_EXECUTION_ID) references BATCH_STEP_EXECUTION (STEP_EXECUTION_ID)
);

create table BATCH_STEP_EXECUTION_SEQ
(
    ID         bigint not null,
    UNIQUE_KEY char   not null,
    constraint UNIQUE_KEY_UN
        unique (UNIQUE_KEY)
);

create table accommodation_reservation
(
    accommodation_reservation_id          int unsigned auto_increment comment '숙박 예약 ID'
        primary key,
    facility_reservation_id               int unsigned       not null comment '시설 예약 ID',
    use_start_date_time                   bigint unsigned    not null comment '사용시작일시(YYYY-MM-DD HH:MM:SS)',
    use_end_date_time                     bigint unsigned    not null comment '사용종료일시(YYYY-MM-DD HH:MM:SS)',
    status                                tinyint default 1  not null comment '예약 상태(0: 취소, 1: 예약)',
    previous_accommodation_reservation_id int unsigned       null comment '연박시 이전 숙박 ID',
    guest_count                           int     default 1  not null comment '예약인원',
    is_deleted                            tinyint default 0  not null comment '삭제 여부(0: false, 1: true)',
    shard_seq                             int     default 11 null,
    created_date_time                     bigint unsigned    not null comment '생성 일시',
    updated_date_time                     bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_accommodation_reservation_unix_timestamp_trigger
    before insert
    on accommodation_reservation
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_accommodation_reservation_unix_timestamp_trigger
    before update
                      on accommodation_reservation
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table apt_detail
(
    apt_id            int unsigned    not null comment '아파트 ID'
        primary key,
    contact           varchar(32)     null comment '아파트 연락처',
    zip_code          varchar(10)     null comment '타석 ID',
    address           varchar(255)    null comment '주소',
    shard_seq         int default 11  null,
    created_date_time bigint unsigned not null comment '생성 일시',
    updated_date_time bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_apt_detail_unix_timestamp_trigger
    before insert
    on apt_detail
    for each row
BEGIN
    SET
NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_apt_detail_unix_timestamp_trigger
    before update
                      on apt_detail
                      for each row
BEGIN
    SET
NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table batter_box
(
    batter_box_id      int unsigned auto_increment comment '타석 ID'
        primary key,
    facility_id        int unsigned       not null comment '시설 ID',
    number             smallint           not null comment '타석 번호',
    code               smallint           null comment '타석제어기 연결 코드(1~0000)',
    type               tinyint default 1  not null comment '타석종류 (1:일반, 2:스크린=GDR)',
    hand_type          tinyint default 1  not null comment '타석형태 (1: 우타, 2: 좌타,  3: 좌우타 겸용)',
    pair_batter_box_id int unsigned       null comment '좌우타 겸용 페어 타석 ID',
    is_mobile          tinyint default 1  not null comment '모바일 배정 (0:불가, 1:가능)',
    is_kiosk           tinyint default 1  not null comment '키오스크 배정 (0:불가, 1:가능)',
    status             tinyint default 1  not null comment '상태 (1:이용가능, 2:레슨중, 3:점검중)',
    remark             varchar(20)        null comment '비고(~ 10자)',
    is_available       tinyint default 1  not null comment '사용 여부 (0: FALSE, 1: TRUE)',
    is_deleted         tinyint default 0  not null comment '삭제 여부 (0: FALSE, 1: TRUE)',
    shard_seq          int     default 11 null,
    created_date_time  bigint unsigned    not null comment '생성 일시',
    updated_date_time  bigint unsigned    null comment '수정 일시'
);

create index batter_box_facility_id_index
    on batter_box (facility_id);

create definer = admin@`%` trigger create_batter_box_unix_timestamp_trigger
    before insert
    on batter_box
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_batter_box_unix_timestamp_trigger
    before update
                      on batter_box
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table batter_box_available_ticket
(
    batter_box_available_ticket_id int unsigned auto_increment comment '타석 가능 이용권 ID'
        primary key,
    ticket_id                      int unsigned    null comment '이용권ID-좌석사용가능이용권할당',
    batter_box_id                  int unsigned    not null comment '타석 ID',
    facility_id                    int unsigned    not null comment '시설 ID',
    shard_seq                      int default 11  null,
    created_date_time              bigint unsigned not null comment '생성 일시',
    updated_date_time              bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_batter_box_available_ticket_unix_timestamp_trigger
    before insert
    on batter_box_available_ticket
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_batter_box_available_ticket_unix_timestamp_trigger
    before update
                      on batter_box_available_ticket
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table batter_box_reservation
(
    batter_box_reservation_id int unsigned auto_increment comment '타석 예약 ID'
        primary key,
    facility_reservation_id   int unsigned             not null comment '시설예약 ID',
    batter_box_id             int unsigned             not null comment '타석ID',
    use_start_date_time       bigint unsigned          not null comment '사용시작일시(YYYY-MM-DD HH:MM:SS)',
    use_end_date_time         bigint unsigned          not null comment '사용종료일시(YYYY-MM-DD HH:MM:SS)',
    extended_time             int unsigned default '0' not null comment '연장시간(분)',
    status                    tinyint      default 1   not null comment '예약 상태(0: 취소, 1: 예약)',
    is_deleted                tinyint      default 0   not null comment '삭제 여부(0: false, 1: true)',
    reservation_date          bigint unsigned          null comment '예약일',
    start_time                int unsigned             null comment '예약 시작 시간',
    end_time                  int unsigned             null comment '예약 종료 시간',
    shard_seq                 int          default 11  null,
    created_date_time         bigint unsigned          not null comment '생성 일시',
    updated_date_time         bigint unsigned          null comment '수정 일시'
);

create index batter_box_reservation_batter_box_id_index
    on batter_box_reservation (batter_box_id);

create definer = admin@`%` trigger create_batter_box_reservation_unix_timestamp_trigger
    before insert
    on batter_box_reservation
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_batter_box_reservation_unix_timestamp_trigger
    before update
                      on batter_box_reservation
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table batter_box_sort_order
(
    batter_box_sort_order_id int unsigned auto_increment comment '타석 정렬 ID'
        primary key,
    batter_box_id            int unsigned    not null comment '타석 ID',
    facility_id              int unsigned    not null comment '고유',
    sort_order               int unsigned    null comment '정렬 순서',
    shard_seq                int default 11  null,
    created_date_time        bigint unsigned not null comment '생성 일시',
    updated_date_time        bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_batter_box_sort_order_unix_timestamp_trigger
    before insert
    on batter_box_sort_order
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_batter_box_sort_order_unix_timestamp_trigger
    before update
                      on batter_box_sort_order
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table batter_box_time_restriction
(
    batter_box_time_restriction_id int unsigned auto_increment comment '타석 타임 제한 ID'
        primary key,
    facility_id                    int unsigned    not null comment '시설 ID',
    batter_box_id                  int unsigned    not null comment '타석 ID',
    facility_timetable_id          int unsigned    not null comment '시설 타임테이블 ID',
    date                           bigint unsigned not null comment '일자',
    restriction_type               tinyint         not null comment '제한 종류(1: 사용안함, 2: 레슨중, 3: 점검중)',
    shard_seq                      int default 11  null,
    created_date_time              bigint unsigned not null comment '생성일시',
    updated_date_time              bigint unsigned null comment '수정일시'
);

create index idx_batter_box_time_restriction_facility_id__timetable_id_date
    on batter_box_time_restriction (facility_id, facility_timetable_id, date);

create definer = admin@`%` trigger create_batter_box_time_restriction_unix_timestamp_trigger
    before insert
    on batter_box_time_restriction
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_batter_box_time_restriction_unix_timestamp_trigger
    before update
                      on batter_box_time_restriction
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
end;

create table blacklist
(
    blacklist_id      int unsigned auto_increment comment '블랙리스트 ID'
        primary key,
    member_id         int unsigned       not null comment '유저 ID',
    start_date        bigint unsigned    not null comment '시작 일자',
    end_date          bigint unsigned    not null comment '종료 일자',
    is_deleted        tinyint default 0  not null comment '삭제여부(0: false, 1:true)',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    null comment '수정 일시'
);

create index blacklist_member_id_IDX
    on blacklist (member_id, is_deleted);

create definer = admin@`%` trigger create_blacklist_unix_timestamp_trigger
    before insert
    on blacklist
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_blacklist_unix_timestamp_trigger
    before update
                      on blacklist
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table card
(
    card_id           int unsigned auto_increment comment '카드 고유키'
        primary key,
    apt_id            int unsigned       not null comment '아파트 고유키',
    member_id         int unsigned       not null comment '유저 고유키',
    card_number       varchar(16)        not null comment '카드 번호',
    status            tinyint default 1  not null comment '카드 상태(1: 발급, 2:분실, 3:정지)',
    type              tinyint default 1  not null comment '카드 종류(1: 입주민, 2: 독서실, 3:모바일)',
    is_master_card    tinyint default 0  not null comment '마스터카드여부(0: FALSE, 1: TRUE)',
    remark            varchar(1000)      null comment '비고',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    null comment '수정 일시',
    issued_date       bigint unsigned    not null comment '발급 일자'
);

create definer = admin@`%` trigger create_card_unix_timestamp_trigger
    before insert
    on card
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_card_unix_timestamp_trigger
    before update
                      on card
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table common_config
(
    common_config_id            int unsigned auto_increment comment '공통환경설정 ID'
        primary key,
    apt_id                      int unsigned default '0'  not null comment '아파트 ID',
    payment_method              tinyint      default 1    not null comment '결제방법(1: 관리비, 2:신용카드)',
    rounding_amount_unit        tinyint      default 1    not null comment '금액 반올림 단위 (1:원, 2:십, 3:백, 4:천)',
    is_electronic_key           tinyint      default 0    not null comment '전자키 사용여부 (0: 사용안함, 1:사용함)',
    is_print_electronic_key     tinyint      default 0    not null comment '전자키 출력여부 (0: 사용안함, 1:사용함)',
    is_link_hand_key            tinyint      default 0    not null comment '핸드키연동여부 (0: 사용안함, 1:사용함)',
    locker_ticket_issue_type    tinyint      default 1    not null comment '사물함 발권 방식 (1: 자동발권, 2:상하단선택)',
    is_electronic_key_situation tinyint      default 0    not null comment '전자키 현황표시 (0:사용안함, 1:사용함)',
    admin_receipts_print_count  tinyint      default 0    not null comment '관리자 영수증 출력 개수',
    settlement_date             tinyint      default 1    not null comment '정산 기준 (1: 이용일, 2: 결제일)',
    shard_seq                   int unsigned default '11' null,
    created_date_time           bigint unsigned           not null comment '등록일시',
    updated_date_time           bigint unsigned           null comment '수정일시'
);

create definer = admin@`%` trigger create_common_config_unix_timestamp_trigger
    before insert
    on common_config
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_common_config_unix_timestamp_trigger
    before update
                      on common_config
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table community_coupon
(
    community_coupon_id     int unsigned auto_increment comment '커뮤니티 쿠폰 ID'
        primary key,
    apt_id                  int unsigned    not null comment '아파트 ID',
    community_coupon_type   tinyint         not null comment '구분(1: 통합, 2: 개별)',
    monthly_available_count int unsigned    not null comment '월 이용가능 횟수',
    daily_available_count   int unsigned    not null comment '일 이용가능 횟수',
    shard_seq               int default 11  null,
    created_date_time       bigint unsigned not null comment '생성 일시',
    updated_date_time       bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_community_coupon_unix_timestamp_trigger
    before insert
    on community_coupon
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_community_coupon_unix_timestamp_trigger
    before update
                      on community_coupon
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table community_coupon_facility
(
    community_coupon_facility_id int unsigned auto_increment comment '커뮤니티 쿠폰 시설 ID'
        primary key,
    community_coupon_id          int unsigned    not null comment '커뮤니티 쿠폰 ID',
    shard_seq                    int default 11  null,
    created_date_time            bigint unsigned not null comment '생성 일시',
    updated_date_time            bigint unsigned null comment '수정 일시',
    facility_type_id             int unsigned    not null
);

create definer = admin@`%` trigger create_community_coupon_facility_unix_timestamp_trigger
    before insert
    on community_coupon_facility
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_community_coupon_facility_unix_timestamp_trigger
    before update
                      on community_coupon_facility
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table coupon_usage_history
(
    coupon_usage_history_id int unsigned auto_increment comment '쿠폰 사용내역 ID'
        primary key,
    family_id               int unsigned       not null comment '세대 고유키',
    member_id               int unsigned       not null comment '입주민 ID',
    facility_type_id        int unsigned       not null comment '시설 종류 ID',
    facility_id             int unsigned       not null comment '시설 ID',
    sales_detail_id         int unsigned       not null comment '매출 상세 ID',
    used_count              int                not null comment '쿠폰 사용 갯수',
    status                  tinyint default 1  not null comment '쿠폰 사용상태(0: 취소, 1: 사용함)',
    used_date_time          bigint unsigned    not null comment '사용일시',
    cancelled_date_time     bigint unsigned    null comment '취소일시',
    created_date_time       bigint unsigned    not null comment '생성일시',
    updated_date_time       bigint unsigned    null comment '수정일시',
    shard_seq               int     default 11 null,
    is_deleted              tinyint default 0  not null comment '삭제여부(0: false, 1: true)'
);

create index idx_coupon_usage_history_member_id_used_date_time
    on coupon_usage_history (member_id, used_date_time);

create definer = admin@`%` trigger create_coupon_usage_history_unix_timestamp_trigger
    before insert
    on coupon_usage_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_coupon_usage_history_unix_timestamp_trigger
    before update
                      on coupon_usage_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table dongho
(
    dongho_id                     int unsigned auto_increment
        primary key,
    apt_id                        int unsigned       not null comment '아파트 ID',
    dong                          varchar(20)        not null comment '동',
    ho                            varchar(20)        not null comment '호',
    is_available_community_coupon tinyint default 1  not null comment '커뮤니티 쿠폰 사용여부',
    family_id                     int unsigned       null comment '세대 ID',
    migrated_date                 bigint unsigned    null comment '입주 일자',
    shard_seq                     int     default 11 null,
    created_date_time             bigint unsigned    not null comment '생성 일시',
    updated_date_time             bigint unsigned    null comment '수정 일시',
    constraint UK_dongho
        unique (apt_id, dong, ho)
)
    comment '동호 테이블';

create index dongho_family_id_index
    on dongho (family_id);

create definer = admin@`%` trigger create_dongho_unix_timestamp_trigger
    before insert
    on dongho
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_dongho_unix_timestamp_trigger
    before update
                      on dongho
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table face
(
    face_id           int unsigned auto_increment comment '안면정보 ID'
        primary key,
    member_id         int unsigned       not null comment '유저 고유키',
    apt_id            int unsigned       not null comment '아파트 ID',
    type              tinyint default 1  not null comment '안면인식 타입(1: 이미지, 2: 템플릿, 3: 템플릿 + 이미지)',
    image_path        varchar(255)       null comment '사진경로',
    template_data     longblob           null comment '이미지 템플릿 데이터',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    not null comment '수정 일시',
    is_deleted        tinyint default 0  not null comment '삭제여부(0: false, 1: true)'
);

create index face_member_id_IDX
    on face (member_id, is_deleted);

create index idx_face_apt_id_image_path
    on face (apt_id, image_path);

create index idx_face_apt_id_member_id_updated_date_time
    on face (apt_id asc, member_id desc, updated_date_time desc);

create index idx_face_apt_id_template_data
    on face (apt_id, template_data(100));

create definer = admin@`%` trigger create_face_unix_timestamp_trigger
    before insert
    on face
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_face_unix_timestamp_trigger
    before update
                      on face
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table face_device_fail_history
(
    face_device_fail_history_id int unsigned auto_increment comment '안면정보 ID'
        primary key,
    member_id                   int unsigned    not null comment '입주민 ID',
    device_name                 varchar(50)     null comment '단말기 명칭',
    failed_date_time            bigint unsigned not null comment '실패일시',
    fail_message                varchar(200)    null comment '실패메시지',
    shard_seq                   int default 11  null,
    created_date_time           bigint unsigned not null comment '생성 일시',
    updated_date_time           bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_face_device_fail_history_unix_timestamp_trigger
    before insert
    on face_device_fail_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_face_device_fail_history_unix_timestamp_trigger
    before update
                      on face_device_fail_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility
(
    facility_id                      int unsigned auto_increment
        primary key,
    apt_id                           int unsigned       not null,
    facility_type_id                 int unsigned       null comment '시설 종류 ID',
    name                             varchar(32)        not null,
    display_image_address            varchar(1200)      null comment '시설 대표 이미지',
    is_kiosk                         tinyint            null comment '0: FALSE, 1: TRUE, NULL',
    is_mobile                        tinyint            null comment '0: FALSE, 1: TRUE, NULL',
    is_kiosk_cancel                  tinyint default 0  not null comment '0: FALSE, 1: TRUE',
    is_mobile_cancel                 tinyint default 0  not null comment '0: FALSE, 1: TRUE',
    kiosk_cancel_deadline_time_unit  tinyint default 0  not null comment '키오스크 취소/환불 불가 시간 단위(0: 사용안함, 1: 분, 2: 일)',
    kiosk_cancel_deadline_time       int unsigned       null comment '시작전 키오스크 취소/환불 불가 시간',
    mobile_cancel_deadline_time_unit tinyint default 0  not null comment '모바일 취소/환불 불가 시간 단위(0: 사용안함, 1: 분, 2:일)',
    mobile_cancel_deadline_time      int unsigned       null comment '시작전 모바일 취소/환불 불가 시간',
    permitted_gender                 tinyint            null comment '0: ALL 1:MALE, 2: FEMALE',
    is_available                     tinyint            not null comment '0: FALSE, 1: TRUE',
    is_deleted                       tinyint            null comment '0: FALSE, 1: TRUE, NULL',
    sort_order                       tinyint            null,
    shard_seq                        int     default 11 null,
    created_date_time                bigint unsigned    not null,
    updated_date_time                bigint unsigned    null
);

create index idx_facility_apt_id
    on facility (apt_id);

create definer = admin@`%` trigger facility_creation_timestamp_trigger
    before insert
    on facility
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger facility_update_timestamp_trigger
    before update
                      on facility
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_break_time
(
    facility_break_time_id       int unsigned auto_increment
        primary key,
    facility_operation_period_id int unsigned   not null,
    break_start_time             int unsigned   not null,
    break_end_time               int unsigned   not null,
    shard_seq                    int default 11 null
);

create table facility_config_batter_box
(
    facility_id                        int unsigned       not null comment '시설 ID'
        primary key,
    same_assignment_limit_count        int unsigned       null comment '동일타석 배정 제한횟수(null 제한없음) - 하루기준',
    is_gdr_batter_box_additional_price tinyint default 0  not null comment '스크린타석 추가금액 사용여부(0: false, 1: true)',
    shard_seq                          int     default 11 null,
    created_date_time                  bigint unsigned    not null comment '생성 일시',
    updated_date_time                  bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_config_batter_box_unix_timestamp_trigger
    before insert
    on facility_config_batter_box
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_config_batter_box_unix_timestamp_trigger
    before update
                      on facility_config_batter_box
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_config_common
(
    facility_id                 int unsigned             not null comment '시설 ID'
        primary key,
    is_available_proxy_payment  tinyint      default 0   not null comment '세대원 대리결제 사용 여부(0: 사용안함, 1: 사용함)',
    is_additional_item          tinyint      default 0   not null comment '추가상품사용여부(0: FALSE, 1: TRUE)',
    item_limit_count            int unsigned default '0' not null comment '상품별 최대구매 갯수',
    single_use_duration_minutes int unsigned             null comment '일 이용가능시간(분) - 입장시간부터 ~',
    issue_type                  tinyint      default 1   not null comment '발권타입(1: 자동발권, 2: 수동발권)',
    manual_issue_platform       tinyint      default 1   null comment '수동발권 플랫폼 ( 1: 키오스크+관리자, 2: 관리자)',
    shard_seq                   int          default 11  null,
    created_date_time           bigint unsigned          not null comment '생성 일시',
    updated_date_time           bigint unsigned          null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_config_common_unix_timestamp_trigger
    before insert
    on facility_config_common
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_config_common_unix_timestamp_trigger
    before update
                      on facility_config_common
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_config_electronic_key
(
    facility_id       int unsigned             not null comment '시설 ID'
        primary key,
    host              varchar(200)             not null comment '호스트/IP',
    port              int unsigned             not null comment '포트(0~65535)',
    place_number      int unsigned default '1' not null comment '구역번호',
    sub_number        int unsigned default '0' not null comment '서브번호',
    corporation       varchar(10)              not null comment '업체코드',
    is_available      tinyint      default 1   not null comment '사용여부(0: false, 1: true)',
    shard_seq         int          default 11  null,
    created_date_time bigint unsigned          not null comment '생성 일시',
    updated_date_time bigint unsigned          null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_electronic_key_config_unix_timestamp_trigger
    before insert
    on facility_config_electronic_key
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_electronic_key_config_unix_timestamp_trigger
    before update
                      on facility_config_electronic_key
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_config_first_come_reservation
(
    facility_id                 int unsigned       not null comment '시설 ID'
        primary key,
    usage_time_minutes          int unsigned       not null comment '기본이용시간(분)',
    waiting_time_minutes        int unsigned       not null comment '대기시간(분)',
    is_additional_time          tinyint default 0  not null comment '추가시간 사용여부(0: false, 1: true)',
    additional_time_limit_count int unsigned       null comment '추가이용제한횟수(선착순배정인 경우 사용가능, null 제한없음)',
    shard_seq                   int     default 11 null,
    created_date_time           bigint unsigned    not null comment '생성 일시',
    updated_date_time           bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_config_first_reservation_unix_timestamp_trigger
    before insert
    on facility_config_first_come_reservation
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_config_first_reservation_unix_timestamp_trigger
    before update
                      on facility_config_first_come_reservation
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_config_fitness
(
    facility_config_fitness_id                         int unsigned auto_increment comment '피트니스 환경설정 ID'
        primary key,
    facility_id                                        int unsigned       not null comment '시설ID',
    pre_admission_time_minutes_before_ticket_start     smallint unsigned  null comment '프로그램 시작전 입장가능 시간(분)',
    is_available_item                                  tinyint default 0  not null comment '상품정보(0:사용안함, 1:사용)',
    additional_item_limit_count                        smallint unsigned  null comment '추가상품 제한횟수',
    is_available_new_registration_by_registered_member tinyint default 0  not null comment '재등록 회원의 신규 등록 가능 여부(0: 등록 불가능, 1: 등록 가능)',
    is_available_proxy_payment                         tinyint default 0  not null comment '세대원 대리결제 사용 여부(0: 사용안함, 1: 사용함)',
    shard_seq                                          int     default 11 null,
    created_date_time                                  bigint unsigned    not null comment '생성 일시',
    updated_date_time                                  bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_config_fitness_unix_timestamp_trigger
    before insert
    on facility_config_fitness
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_config_fitness_unix_timestamp_trigger
    before update
                      on facility_config_fitness
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_config_golf
(
    facility_config_golf_id                            int unsigned auto_increment comment '시설골프ID'
        primary key,
    facility_id                                        int unsigned                  not null comment '시설ID',
    time_operation_method                              tinyint           default 0   not null comment '운영방식(1: 타임테이블, 2: 선착순배정)',
    usage_time_minutes                                 smallint unsigned default '0' not null comment '기본이용시간(분)',
    waiting_time_minutes                               smallint unsigned             null comment '대기시간(분)',
    additional_time_minutes                            smallint unsigned             null comment '추가이용가능시간(분) (선착순배정인 경우 사용가능)',
    additional_time_limit_count                        smallint unsigned             null comment '추가이용제한횟수(선착순배정인 경우 사용가능)',
    additional_time_request_platform                   tinyint                       null comment '추가시간 요청대상( 0: 전체, 1: 관리자, 2: 키오스크/모바일)',
    daily_assignment_limit_count                       smallint unsigned             null comment '당일 배정 제한횟수',
    same_assignment_limit_count                        smallint unsigned             null comment '동일타석 배정 제한횟수',
    reservation_time_type                              tinyint           default 1   not null comment '타석 예약 타입(1: 오늘만 예약, 2: 오늘+내일예약)',
    pre_reservation_time_minutes_before_facility_open  smallint unsigned             null comment '시설 운영시간 시작 전 타석 예약 가능 시간(분)',
    is_admission_created                               tinyint           default 1   not null comment '배정시 입장정보(0: 생성안함, 1: 생성)',
    pre_admission_time_before_ticket_start             smallint unsigned             null comment '이용권 시작 전 입장 가능시간(분)',
    is_available_item                                  tinyint           default 0   not null comment '상품정보 (0:사용안함, 1:사용)',
    additional_item_limit_count                        smallint unsigned             null comment '추가상품 제한횟수',
    is_available_new_registration_by_registered_member tinyint           default 0   not null comment '재등록 회원의 신규 등록 가능 여부(0: 등록 불가능, 1: 등록 가능)',
    is_available_proxy_payment                         tinyint           default 0   not null comment '세대원 대리결제 사용 여부(0: 사용안함, 1: 사용함)',
    shard_seq                                          int               default 11  null,
    created_date_time                                  bigint unsigned               not null comment '생성 일시',
    updated_date_time                                  bigint unsigned               null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_config_golf_unix_timestamp_trigger
    before insert
    on facility_config_golf
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_config_golf_unix_timestamp_trigger
    before update
                      on facility_config_golf
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_config_locker
(
    facility_id       int unsigned       not null comment '시설 ID'
        primary key,
    is_auto_return    tinyint default 1  not null comment '사물함 자동반납 사용여부 (0: false, 1: true)',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_config_locker_unix_timestamp_trigger
    before insert
    on facility_config_locker
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_config_locker_unix_timestamp_trigger
    before update
                      on facility_config_locker
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_config_public_room
(
    facility_id                           int unsigned       not null comment '시설 ID'
        primary key,
    is_available_enter_for_private_ticket tinyint default 1  not null comment '개인레슨,PT이용권 입장가능여부(0: false, 1: true)',
    shard_seq                             int     default 11 null,
    created_date_time                     bigint unsigned    not null comment '생성 일시',
    updated_date_time                     bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_config_public_room_unix_timestamp_trigger
    before insert
    on facility_config_public_room
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_config_public_room_unix_timestamp_trigger
    before update
                      on facility_config_public_room
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_config_reservation
(
    facility_id                      int unsigned       not null comment '시설 ID'
        primary key,
    access_type                      tinyint default 0  not null comment '예약 허용 타입(0: 제한없음, 1: 골프장 정기권 이용자만)',
    reservation_days_type            tinyint            null comment '예약가능일수제한 타입(1: 일, 2: 주, 3: 월)',
    reservation_days                 int unsigned       null comment '예약가능일수제한(오늘부터 ~)',
    is_available_today_reservation   tinyint default 0  not null comment '당일예약 허용여부(0: false, 1: true)',
    reservation_time_slots           int unsigned       null comment '선택가능한 시간 슬롯 수(날짜: 연박일수, 시간: 연속타임)',
    reservation_limit_standard       tinyint default 1  not null comment '예약제한기준 (1:개인별, 2:세대별)',
    reservation_limit_cycle          tinyint default 1  not null comment '예약제한주기 (1:1일, 2:1주, 3:1개월)',
    reservation_limit_count          int unsigned       null comment '예약최대제한횟수(NULL 제한없음)',
    available_reservation_start_time int unsigned       null comment '예약가능 시작시간',
    available_reservation_end_time   int unsigned       null comment '예약가능 종료시간',
    is_available_all_day             tinyint default 0  not null comment '24시간 예약가능여부(0: false, 1: true)',
    shard_seq                        int     default 11 null,
    created_date_time                bigint unsigned    not null comment '생성 일시',
    updated_date_time                bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_config_reservation_unix_timestamp_trigger
    before insert
    on facility_config_reservation
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_config_reservation_unix_timestamp_trigger
    before update
                      on facility_config_reservation
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_config_seat
(
    facility_id                                          int unsigned       not null comment '시설 ID'
        primary key,
    is_auto_return                                       tinyint default 1  not null comment '자동반납 사용여부(0: false, 1: true)',
    is_seat_selection_required_for_manual_reregistration tinyint            null,
    shard_seq                                            int     default 11 null,
    created_date_time                                    bigint unsigned    not null comment '생성 일시',
    updated_date_time                                    bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_config_seat_unix_timestamp_trigger
    before insert
    on facility_config_seat
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_config_seat_unix_timestamp_trigger
    before update
                      on facility_config_seat
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_detail
(
    facility_detail_id int unsigned auto_increment
        primary key,
    facility_id        int unsigned   not null,
    description        varchar(100)   null comment '설명',
    usage_guide        text           null comment '이용안내',
    location           varchar(30)    not null comment '위치',
    ticket_note        varchar(200)   null comment '이용권 유의사항',
    shard_seq          int default 11 null,
    detail_description text           null comment '상세설명',
    notice             text           null comment '공지사항'
);

create index idx_facility_detail_facility_id
    on facility_detail (facility_id);

create table facility_image
(
    facility_image_id int unsigned auto_increment
        primary key,
    facility_id       int unsigned    not null,
    image_address     varchar(1200)   not null,
    image_type        tinyint         not null,
    shard_seq         int default 11  null,
    created_date_time bigint unsigned null
);

create index idx_facility_image_facility_id_image_type
    on facility_image (facility_id, image_type);

create definer = admin@`%` trigger facility_image_creation_timestamp_trigger
    before insert
    on facility_image
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_operation_period
(
    facility_operation_period_id int unsigned auto_increment
        primary key,
    facility_id                  int unsigned    not null,
    open_date                    bigint unsigned null,
    close_date                   bigint unsigned null,
    is_break_time_used           tinyint         not null,
    shard_seq                    int default 11  null
);

create index idx_facility_operation_period_facility_id
    on facility_operation_period (facility_id);

create table facility_operation_time
(
    facility_operation_time_id   int unsigned auto_increment
        primary key,
    facility_operation_period_id int unsigned   not null,
    open_time                    int unsigned   null,
    close_time                   int unsigned   null,
    type                         tinyint        not null,
    shard_seq                    int default 11 null
);

create index idx_facility_operation_time_facility_operation_period_id
    on facility_operation_time (facility_operation_period_id);

create table facility_operation_time_override
(
    facility_operation_time_override_id        int unsigned auto_increment comment '시설 변동 운영일 ID'
        primary key,
    facility_id                                int unsigned    not null comment '시설 ID',
    facility_operation_time_override_repeat_id int unsigned    null comment '시설 변동 운영일 반복ID',
    type                                       tinyint         null comment '변동타입(1:DAY_OFF(휴무일), 2: EXCEPTIONAL_OPERATION_TIME(변동운영),3:SURCHARGE(할증일))',
    open_time                                  int unsigned    null comment '운영시작시간',
    close_time                                 int unsigned    null comment '운영종료시간',
    date                                       bigint unsigned null comment '변동 날짜',
    is_repeated                                tinyint         null comment '반복유무(0: 안함, 1:사용)',
    shard_seq                                  int default 11  null,
    created_date_time                          bigint unsigned not null comment '생성 일시',
    updated_date_time                          bigint unsigned null comment '수정 일시',
    facility_name                              varchar(32)     not null,
    facility_type_id                           int             not null
);

create index idx_facility_operation_time_override_facility_id_type_date
    on facility_operation_time_override (facility_id, type, date);

create definer = admin@`%` trigger create_facility_operation_change_unix_timestamp_trigger
    before insert
    on facility_operation_time_override
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_operation_change_unix_timestamp_trigger
    before update
                      on facility_operation_time_override
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_operation_time_override_repeat
(
    facility_operation_time_override_repeat_id int unsigned auto_increment
        primary key,
    facility_id                                int unsigned    not null,
    repeat_start_date                          bigint unsigned null,
    repeat_end_date                            bigint unsigned null,
    repeat_day_of_the_week                     varchar(100)    null,
    created_date_time                          bigint unsigned null,
    shard_seq                                  int default 11  null
);

create definer = admin@`%` trigger operation_time_override_repeat_creation_timestamp_trigger
    before insert
    on facility_operation_time_override_repeat
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_reservation
(
    facility_reservation_id     int unsigned auto_increment comment '시설 예약 ID'
        primary key,
    ticket_own_id               int unsigned       not null comment '이용권 보유 ID',
    ticket_id                   int unsigned       not null comment '이용권 ID',
    facility_id                 int unsigned       null comment '시설 ID',
    member_id                   int unsigned       not null comment '입주민 ID',
    sales_id                    int unsigned       null comment '매출 ID',
    type                        tinyint            not null comment '예약 타입(1: BETTER BOX, 2: SEAT, 3: ROOM, 4: LOCKER, 5: ACCOMMODATION)',
    reservation_start_date_time bigint unsigned    null comment '예약 시작 일시(YYYY-MM-DD HH:MM:SS)',
    reservation_end_date_time   bigint unsigned    null comment '예약 종료 일시(YYYY-MM-DD HH:MM:SS)',
    reservation_method          tinyint            not null comment '예약 수단(1: MOBILE, 2: KIOSK, 3: ADMIN)',
    status                      tinyint default 1  not null comment '예약 상태(0: 취소, 1: 예약)',
    cancel_date_time            bigint unsigned    null comment '예약 취소일시',
    is_deleted                  tinyint default 0  not null comment '삭제 여부(0: false, 1: true)',
    shard_seq                   int     default 11 null,
    created_date_time           bigint unsigned    not null comment '생성 일시',
    updated_date_time           bigint unsigned    null comment '수정 일시'
);

create index idx_facility_reservation_member_id_type_start_date_time
    on facility_reservation (member_id, reservation_start_date_time);

create definer = admin@`%` trigger create_facility_reservation_unix_timestamp_trigger
    before insert
    on facility_reservation
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_reservation_unix_timestamp_trigger
    before update
                      on facility_reservation
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_timetable
(
    facility_timetable_id int unsigned auto_increment comment '시설 타임테이블 ID'
        primary key,
    facility_id           int unsigned    not null comment '시설 ID',
    open_date_time        bigint unsigned not null comment '오픈일시',
    close_date_time       bigint unsigned not null comment '마감일시',
    start_time            int unsigned    not null comment '시작시간',
    end_time              int unsigned    not null comment '종료시간',
    shard_seq             int default 11  null,
    created_date_time     bigint unsigned not null comment '생성일시',
    updated_date_time     bigint unsigned null comment '수정일시'
);

create index idx_facility_timetable_facility_id
    on facility_timetable (facility_id);

create definer = admin@`%` trigger create_facility_timetable_unix_timestamp_trigger
    before insert
    on facility_timetable
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_timetable_unix_timestamp_trigger
    before update
                      on facility_timetable
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
end;

create table facility_type
(
    facility_type_id     int unsigned auto_increment comment '시설 타입 ID'
        primary key,
    category             tinyint            not null comment '시설 범주(1: BATTER_BOX, 2: SEAT, 3: LOCKER, 4: PRIVATE_ROOM, 5: PUBLIC_ROOM, 6: CAFETERIA)',
    apt_id               int unsigned       not null comment '아파트 고유키',
    name                 varchar(32)        not null comment '시설 타입 명',
    is_available         tinyint default 1  not null comment '사용여부 (0: false, 1: true)',
    sort_order           tinyint default 1  not null comment '정렬 순서',
    is_regular_ticket    tinyint default 0  not null comment '정기권사용여부(0: FALSE, 1: TRUE)',
    is_temporary_ticket  tinyint default 0  not null comment '기간권사용여부(0: FALSE, 1: TRUE)',
    is_single_use_ticket tinyint default 0  not null comment '1회권사용여부(0: FALSE, 1: TRUE)',
    reservation_type     tinyint default 0  not null comment '예약 타입(0: 사용안함, 1: 날짜, 2: 날짜+시간, 3: 선착순)',
    third_party_type     tinyint default 0  not null comment '외부연동 타입(0: 사용안함, 1: 전자키, 2: 도서대여, 3: 세탁기, 4: 자판기)',
    config_code          varchar(20)        null comment '임시 설정코드(2개 단지 이후 삭제필요)',
    shard_seq            int     default 11 null,
    created_date_time    bigint unsigned    not null comment '생성 일시',
    updated_date_time    bigint unsigned    null comment '수정 일시',
    constraint UK_facility_type
        unique (apt_id, name)
);

create definer = admin@`%` trigger create_facility_type_unix_timestamp_trigger
    before insert
    on facility_type
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_type_unix_timestamp_trigger
    before update
                      on facility_type
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_type_config
(
    facility_type_id               int unsigned             not null comment '시설 타입 ID'
        primary key,
    is_same_facility_type_limit    tinyint      default 0   not null comment '동일 시설 예약제한 사용여부(0: false, 1: true)',
    same_facility_type_limit_count int unsigned default '1' not null comment '동일종류시설 예약제한 횟수(하루단위)',
    is_available_proxy_payment     tinyint      default 0   not null comment '세대원 대리결제 사용 여부(0: 사용안함, 1: 사용함)',
    shard_seq                      int          default 11  null,
    created_date_time              bigint unsigned          not null comment '생성 일시',
    updated_date_time              bigint unsigned          null comment '수정 일시'
);

create definer = admin@`%` trigger create_facility_type_config_unix_timestamp_trigger
    before insert
    on facility_type_config
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_type_config_unix_timestamp_trigger
    before update
                      on facility_type_config
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table facility_usage_fee
(
    facility_usage_fee_id int unsigned auto_increment comment '시설 이용요금 ID'
        primary key,
    facility_id           int unsigned             not null comment '시설 ID',
    category              tinyint      default 1   not null comment '이용요금 유형(1: ENHANCED, 2: ADDITIONAL, 3: OVERTIME)',
    type                  tinyint      default 0   not null comment '요금 타입(0: ALL, 1: BASIC, 2: GDR, )',
    unit_type             tinyint      default 1   not null comment '이용단위 타입(1: PER_USE, 2: PER_MINUTES)',
    unit                  int unsigned default '1' not null comment '이용 단위(횟수, 분)',
    name                  varchar(50)              not null comment '요금 명',
    price                 int unsigned             not null comment '요금',
    is_available          tinyint      default 1   not null comment '사용여부(0: false, 1: true)',
    is_deleted            tinyint      default 0   not null comment '삭제여부(0: false, 1: true)',
    shard_seq             int          default 11  null,
    created_date_time     bigint unsigned          not null comment '생성 일시',
    updated_date_time     bigint unsigned          null comment '수정 일시'
);

create index idx_facility_usage_fee_facility_id_category
    on facility_usage_fee (facility_id, category);

create definer = admin@`%` trigger create_facility_usage_fee_unix_timestamp_trigger
    before insert
    on facility_usage_fee
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_facility_usage_fee_unix_timestamp_trigger
    before update
                      on facility_usage_fee
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table family
(
    family_id         int unsigned auto_increment comment '세대 ID'
        primary key,
    status            tinyint default 1  not null comment '세대 상태',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    null comment '수정 일시'
)
    comment '세대 테이블';

create definer = admin@`%` trigger create_family_unix_timestamp_trigger
    before insert
    on family
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_family_unix_timestamp_trigger
    before update
                      on family
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table finger
(
    finger_id         int unsigned auto_increment comment '지문 ID'
        primary key,
    member_id         int unsigned       not null comment '유저 고유키',
    apt_id            int unsigned       not null comment '아파트 ID',
    type              tinyint            not null comment '지문인식 타입(1: 유니온 타입, 2: 슈프리마 타입)',
    finger_one        text               null comment '유니온 지문1',
    finger_two        text               null comment '유니온 지문2',
    finger_three      text               null comment '유니온 지문3',
    template_data     longblob           null comment '슈프리마 지문',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    not null comment '수정 일시',
    is_deleted        tinyint default 0  not null comment '삭제여부(0: false, 1: true)'
);

create index finger_member_id_IDX
    on finger (member_id, is_deleted);

create index idx_finger_apt_id_type_member_id_updated_date_time
    on finger (apt_id asc, type asc, member_id desc, updated_date_time desc);

create definer = admin@`%` trigger create_finger_unix_timestamp_trigger
    before insert
    on finger
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_finger_unix_timestamp_trigger
    before update
                      on finger
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table gate
(
    gate_id                  int unsigned auto_increment comment '게이트 ID'
        primary key,
    apt_id                   int unsigned                  not null comment '아파트 ID',
    type                     tinyint                       not null comment '게이트 타입(1:입구, 2: 출구)',
    code                     int unsigned                  not null comment '게이트 코드',
    name                     varchar(50)                   not null comment '게이트명',
    location                 varchar(100)                  null comment '게이트 위치',
    authentication_type      tinyint                       not null comment '인증 타입(1: 입주민 확인, 2: 이용권보유 확인, 3: 발권 확인)',
    entrance_opening_minutes smallint unsigned default '0' null comment '입장 시작시간(분) - 운영 시작시간 기준 몇 분 전부터 입장 시작',
    entrance_closing_minutes smallint unsigned default '0' null comment '입장 마감시간(분) - 운영 종료시간 기준 몇 분 전까지 입장 마감',
    is_available             tinyint           default 1   not null comment '게이트 사용여부(0: 미사용, 1: 사용)',
    is_deleted               tinyint           default 0   not null comment '삭제여부(0: false, 1: true)',
    shard_seq                int               default 11  null,
    created_date_time        bigint unsigned               not null comment '생성 일시',
    updated_date_time        bigint unsigned               null comment '수정 일시'
);

create definer = admin@`%` trigger create_gate_unix_timestamp_trigger
    before insert
    on gate
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_gate_unix_timestamp_trigger
    before update
                      on gate
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table gate_admin_access
(
    gate_admin_access_id int unsigned auto_increment comment '출입게이트 관리자 접근권한 ID'
        primary key,
    gate_id              int unsigned    not null comment '게이트 ID',
    member_id            int unsigned    not null comment '유저 고유키 (공용,개별 관리자)',
    shard_seq            int default 11  null,
    created_date_time    bigint unsigned not null comment '생성 일시',
    updated_date_time    bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_gate_admin_access_unix_timestamp_trigger
    before insert
    on gate_admin_access
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_gate_admin_access_unix_timestamp_trigger
    before update
                      on gate_admin_access
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table gate_admin_access_history
(
    gate_admin_access_history_id int unsigned auto_increment comment '관리자출입내역 ID'
        primary key,
    apt_id                       int unsigned       not null comment '아파트 ID',
    member_id                    int unsigned       not null comment '입주민 ID',
    member_name                  varchar(50)        not null comment '입주민명',
    gate_type                    tinyint            not null comment '게이트타입(1:입구,2:출구)',
    gate_name                    varchar(50)        null comment '게이트명',
    authentication_method        tinyint            not null comment '통과 인증수단(0: 미사용, 1: 안면, 2: 지문, 3: 카드)',
    card_number                  varchar(16)        null comment '통과 카드번호',
    is_deleted                   tinyint default 0  not null comment '삭제여부(0: false, 1: true)',
    shard_seq                    int     default 11 null,
    created_date_time            bigint unsigned    not null comment '생성 일시',
    updated_date_time            bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_gate_admin_access_history_unix_timestamp_trigger
    before insert
    on gate_admin_access_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_gate_admin_access_history_unix_timestamp_trigger
    before update
                      on gate_admin_access_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table gate_enter_fail_history
(
    gate_enter_fail_history_id  int unsigned auto_increment comment '입장실패내역 ID'
        primary key,
    apt_id                      int unsigned    not null comment '아파트 ID',
    member_id                   int unsigned    not null comment '입주민 ID',
    dong                        varchar(20)     null comment '동',
    ho                          varchar(20)     null comment '호',
    member_name                 varchar(50)     not null comment '입주민명',
    phone                       varchar(16)     null comment '휴대폰번호',
    enter_gate_name             varchar(50)     not null comment '입구게이트명',
    enter_authentication_method tinyint         not null comment '입장 인증 수단(0: 미사용, 1: 안면, 2: 지문, 3: 카드)',
    enter_card_number           varchar(16)     null comment '입장 카드번호',
    fail_message                text            not null comment '실패 메시지',
    shard_seq                   int default 11  null,
    created_date_time           bigint unsigned not null comment '생성 일시',
    updated_date_time           bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_gate_enter_fail_history_unix_timestamp_trigger
    before insert
    on gate_enter_fail_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_gate_enter_fail_history_unix_timestamp_trigger
    before update
                      on gate_enter_fail_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table gate_enter_history
(
    gate_enter_history_id       int unsigned auto_increment comment '입장내역 ID'
        primary key,
    apt_id                      int unsigned       not null comment '아파트 ID',
    member_id                   int unsigned       not null comment '입주민 ID',
    ticket_issue_id             int unsigned       null comment '발권 ID',
    facility_type_id            int unsigned       null comment '시설종류 ID',
    dong                        varchar(20)        not null comment '동',
    ho                          varchar(20)        not null comment '호',
    member_name                 varchar(50)        not null comment '입주민명',
    phone                       varchar(16)        null comment '휴대폰번호',
    facility_type_name          varchar(50)        null comment '시설 종류명',
    facility_name               varchar(32)        null comment '시설명',
    ticket_item_name            varchar(50)        null comment '이용권/상품명',
    enter_gate_name             varchar(50)        null comment '입구게이트명',
    enter_authentication_method tinyint            not null comment '입장 인증 수단(0: 미사용, 1: 안면, 2: 지문, 3: 카드)',
    gate_authentication_type    tinyint            not null comment '게이트 인증 타입(1: 입주민 확인, 2: 이용권보유 확인, 3: 발권 확인)',
    enter_card_number           varchar(16)        null comment '입장 카드번호',
    entrance_type               tinyint default 1  not null comment '입장구분(1: 입장, 2:재입장)',
    is_deleted                  tinyint default 0  not null comment '삭제여부(0: false, 1: true)',
    shard_seq                   int     default 11 null,
    created_date_time           bigint unsigned    not null comment '생성 일시',
    updated_date_time           bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_gate_enter_history_unix_timestamp_trigger
    before insert
    on gate_enter_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_gate_enter_history_unix_timestamp_trigger
    before update
                      on gate_enter_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table gate_exit_history
(
    gate_enter_history_id      int unsigned       not null comment '입장내역 ID',
    exit_gate_name             varchar(50)        null comment '출구게이트명',
    exit_authentication_method tinyint            not null comment '퇴장 인증수단(0: 미사용, 1: 안면, 2: 지문, 3: 카드)',
    exit_card_number           varchar(16)        null comment '퇴장 카드번호',
    is_deleted                 tinyint default 0  not null comment '삭제여부(0: false, 1: true)',
    shard_seq                  int     default 11 null,
    created_date_time          bigint unsigned    not null comment '생성 일시',
    updated_date_time          bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_gate_exit_history_unix_timestamp_trigger
    before insert
    on gate_exit_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_gate_exit_history_unix_timestamp_trigger
    before update
                      on gate_exit_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table gate_exit_only_history
(
    gate_exit_only_history_id  int unsigned auto_increment comment '퇴장유일내역 ID'
        primary key,
    apt_id                     int unsigned       not null comment '아파트 ID',
    member_id                  int unsigned       not null comment '입주민 ID',
    dong                       varchar(20)        not null comment '동',
    ho                         varchar(20)        not null comment '호',
    member_name                varchar(50)        not null comment '입주민명',
    phone                      varchar(16)        null comment '휴대폰번호',
    exit_gate_name             varchar(50)        null comment '출구게이트명',
    exit_authentication_method tinyint            not null comment '퇴장 인증수단(0: 미사용, 1: 안면, 2: 지문, 3: 카드)',
    exit_card_number           varchar(16)        null comment '퇴장 카드번호',
    is_deleted                 tinyint default 0  not null comment '삭제여부(0: false, 1: true)',
    shard_seq                  int     default 11 null,
    created_date_time          bigint unsigned    not null comment '생성 일시',
    updated_date_time          bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_gate_exit_only_history_unix_timestamp_trigger
    before insert
    on gate_exit_only_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_gate_exit_only_history_unix_timestamp_trigger
    before update
                      on gate_exit_only_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table gate_facility
(
    gate_facility_id        int unsigned auto_increment comment '출입게이트 접근시설 ID'
        primary key,
    gate_id                 int unsigned       not null comment '게이트 ID',
    facility_id             int unsigned       not null comment '시설 ID',
    facility_priority_order tinyint default 0  not null comment '게이트별 시설 사용우선순위',
    shard_seq               int     default 11 null,
    created_date_time       bigint unsigned    not null comment '생성 일시',
    updated_date_time       bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_gate_facility_unix_timestamp_trigger
    before insert
    on gate_facility
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_gate_facility_unix_timestamp_trigger
    before update
                      on gate_facility
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table handkey
(
    handkey_id        int unsigned auto_increment comment '핸드키 ID'
        primary key,
    apt_id            int unsigned       not null comment '아파트 ID',
    member_id         int unsigned       null comment '핸드키 등록(발급)한 유저 고유키',
    name              varchar(100)       null comment '키명칭',
    number            varchar(16)        null comment '키번호',
    gender            tinyint            null comment '(0: 전체, 1:남, 2:여성)',
    is_available      tinyint            null comment '사용여부(0: 사용안함, 1:사용함)',
    is_deleted        tinyint default 0  not null comment '삭제 여부(0: FALSE, 1: TRUE)',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_handkey_unix_timestamp_trigger
    before insert
    on handkey
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_handkey_unix_timestamp_trigger
    before update
                      on handkey
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table item
(
    item_id               int unsigned auto_increment comment '상품 ID'
        primary key,
    facility_id           int unsigned       not null comment '시설 ID',
    type                  tinyint            not null comment '상품타입 (1:일반, 2:관리자전용)',
    name                  varchar(50)        not null comment '상품 이름',
    price                 int unsigned       not null comment '판매단가(원)',
    num_deduction_coupons int unsigned       null comment '커뮤니티 쿠폰차감 갯수(NULL 이면 사용안함)',
    start_date            bigint unsigned    null comment '판매 시작일',
    end_date              bigint unsigned    null comment '판매 종료일',
    start_time            int unsigned       null comment '판매 시작 시간',
    end_time              int unsigned       null comment '판매 종료 시간',
    quantity              int unsigned       null comment '판매가능수량(NULL 이면 제한 없음)',
    is_available          tinyint default 1  not null comment '사용 여부 (0: FALSE, 1: TRUE)',
    is_deleted            tinyint default 0  not null comment '삭제 여부 (0: FALSE, 1: TRUE)',
    shard_seq             int     default 11 null,
    created_date_time     bigint unsigned    not null comment '생성 일시',
    updated_date_time     bigint unsigned    null comment '수정 일시'
);

create index idx_item_facility_id
    on item (facility_id);

create definer = admin@`%` trigger create_item_unix_timestamp_trigger
    before insert
    on item
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_item_unix_timestamp_trigger
    before update
                      on item
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table item_option
(
    item_option_id    int unsigned auto_increment comment '상품 옵션 ID'
        primary key,
    item_id           int unsigned       not null comment '상품 ID',
    name              varchar(50)        not null comment '옵션 이름',
    value             varchar(50)        not null comment '옵션 값',
    price             int unsigned       not null comment '옵션 가격(원)',
    is_available      tinyint default 1  not null comment '사용 여부 (0: FALSE, 1: TRUE)',
    is_deleted        tinyint default 0  not null comment '삭제 여부 (0: FALSE, 1: TRUE)',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_item_option_unix_timestamp_trigger
    before insert
    on item_option
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_item_option_unix_timestamp_trigger
    before update
                      on item_option
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table kiosk_config
(
    application_install_id int unsigned                   not null comment '어플리케이션 인스톨 ID'
        primary key,
    apt_id                 int unsigned                   not null comment '아파트 ID',
    kiosk_name             varchar(20)                    not null comment '키오스크 이름',
    admin_receipt_count    tinyint           default 0    not null comment '관리자용 영수증 출력매수',
    customer_receipt_count tinyint           default 1    not null comment '고객용 영수증 출력매수',
    auto_logout_seconds    smallint unsigned default '60' not null comment '자동 로그아웃 시간(초단위)',
    final_id_verification  tinyint           default 1    not null comment '최종 본인 확인',
    shard_seq              int               default 11   null,
    created_date_time      bigint unsigned                not null comment '생성 일시',
    updated_date_time      bigint unsigned                not null comment '수정 일시'
);

create definer = admin@`%` trigger create_kiosk_config_unix_timestamp_trigger
    before insert
    on kiosk_config
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_kiosk_config_unix_timestamp_trigger
    before update
                      on kiosk_config
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table locker
(
    locker_id         int unsigned auto_increment comment '사물함 ID'
        primary key,
    facility_id       int unsigned       not null comment '시설 ID',
    number            smallint           not null comment '사물함 번호',
    type              tinyint default 0  not null comment '분류 (0:공통, 1:상단, 2:하단, 3:사물함(대), 4:사물함(중), 5:사물함(소))',
    gender            tinyint default 0  not null comment '성별 (0: 공용, 1:남, 2: 여)',
    is_mobile         tinyint default 0  not null comment '모바일 배정 (0: 불가, 1:가능)',
    is_kiosk          tinyint default 0  not null comment '키오스크 배정 (0:불가, 1:가능)',
    is_available      tinyint default 1  not null comment '사용 여부 (0: FALSE, 1: TRUE)',
    is_deleted        tinyint default 0  not null comment '삭제 여부(0: FALSE, 1: TRUE)',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_locker_unix_timestamp_trigger
    before insert
    on locker
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_locker_unix_timestamp_trigger
    before update
                      on locker
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table locker_available_ticket
(
    locker_available_ticket_id int unsigned auto_increment comment '타석 가능 이용권 ID'
        primary key,
    locker_id                  int unsigned    not null comment '사물함 ID',
    ticket_id                  int unsigned    null comment '이용권 ID',
    shard_seq                  int default 11  null,
    created_date_time          bigint unsigned not null comment '생성 일시',
    updated_date_time          bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_locker_available_ticket_unix_timestamp_trigger
    before insert
    on locker_available_ticket
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_locker_available_ticket_unix_timestamp_trigger
    before update
                      on locker_available_ticket
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table locker_reservation
(
    locker_reservation_id   int unsigned auto_increment comment '사물함 예약 ID'
        primary key,
    facility_reservation_id int unsigned       not null comment '시설 예약 ID',
    locker_id               int unsigned       not null comment '사물함 ID',
    use_start_date_time     bigint unsigned    not null comment '사용시작일시(YYYY-MM-DD HH:MM:SS)',
    use_end_date_time       bigint unsigned    not null comment '사용종료일시(YYYY-MM-DD HH:MM:SS)',
    status                  tinyint default 1  not null comment '예약 상태(0: 취소, 1: 예약)',
    is_deleted              tinyint default 0  not null comment '삭제 여부(0: false, 1: true)',
    shard_seq               int     default 11 null,
    created_date_time       bigint unsigned    not null comment '생성 일시',
    updated_date_time       bigint unsigned    null comment '수정 일시',
    returned_date_time      bigint unsigned    null comment '반납일시'
);

create definer = admin@`%` trigger create_locker_reservation_unix_timestamp_trigger
    before insert
    on locker_reservation
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_locker_reservation_unix_timestamp_trigger
    before update
                      on locker_reservation
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table locker_sort_order
(
    locker_sort_order_id int unsigned auto_increment comment '좌석 정렬 ID'
        primary key,
    locker_id            int unsigned    not null comment '사물함 ID',
    facility_id          int unsigned    not null comment '시설ID',
    sort_order           int unsigned    null comment '정렬 순서',
    shard_seq            int default 11  null,
    created_date_time    bigint unsigned not null comment '생성 일시',
    updated_date_time    bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_locker_sort_order_unix_timestamp_trigger
    before insert
    on locker_sort_order
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_locker_sort_order_unix_timestamp_trigger
    before update
                      on locker_sort_order
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table member
(
    member_id         int unsigned       not null comment '입주민 ID'
        primary key,
    family_id         int unsigned       null comment '세대 ID',
    apt_id            int unsigned       not null comment '아파트 ID',
    name              varchar(50)        not null comment '입주민명',
    status            tinyint default 1  not null comment '유저 상태(0: 미사용, 1: 사용, 2: 정지)',
    type              tinyint default 2  not null comment '입주민 타입(1: 세대주, 2: 세대원, 3: 공용관리자, 4: 개인관리자)',
    is_deleted        tinyint default 0  not null comment '삭제 여부(0: FALSE, 1: TRUE)',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    null comment '수정 일시'
)
    comment '입주민';

create index idx_member_family_id
    on member (family_id);

create definer = admin@`%` trigger create_member_unix_timestamp_trigger
    before insert
    on member
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_member_unix_timestamp_trigger
    before update
                      on member
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table payment_imposition_option
(
    payment_imposition_option_id int unsigned auto_increment comment '결제금액 부과옵션 ID'
        primary key,
    ticket_id                    int unsigned    not null comment '이용권 ID',
    program_ticket_id            int unsigned    not null comment '프로그램 이용권 ID',
    user_count                   int             not null comment '결제 인원수(명)',
    charge                       int             not null comment '결제 금액',
    shard_seq                    int default 11  null,
    created_date_time            bigint unsigned not null comment '생성 일시',
    updated_date_time            bigint unsigned null comment '수정 일시'
)
    comment '결제금액 부과옵션';

create definer = admin@`%` trigger create_payment_imposition_option_unix_timestamp_trigger
    before insert
    on payment_imposition_option
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_payment_imposition_option_unix_timestamp_trigger
    before update
                      on payment_imposition_option
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table profile
(
    profile_id        int unsigned auto_increment comment '프로필 ID'
        primary key,
    member_id         int unsigned       not null comment '입주민 ID',
    gender            tinyint default 1  not null comment '성별 (1:남, 2: 여)',
    birth_date        date               null comment '생년월일',
    phone             varchar(16)        null comment '연락처',
    remark            varchar(512)       null comment '비고',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    null comment '수정 일시'
)
    comment '입주민';

create index profile_member_id_IDX
    on profile (member_id);

create definer = admin@`%` trigger create_profile_unix_timestamp_trigger
    before insert
    on profile
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_profile_unix_timestamp_trigger
    before update
                      on profile
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table program_regular_ticket
(
    program_regular_ticket_id    int unsigned auto_increment comment '프로그램 정기이용권 ID'
        primary key,
    ticket_id                    int unsigned    not null comment '이용권 ID',
    program_ticket_id            int unsigned    not null comment '프로그램 이용권 ID',
    next_ticket_id               int unsigned    null comment '다음 재등록 이용권 ID',
    re_registration_type         tinyint         not null comment '재등록 타입(1: AUTO, 2: MANUAL, 3: ONLY_NEW)',
    regular_ticket_end_date_type tinyint         not null comment '이용권 종료일(1: LAST_DATE, 2: NEXT_PAY)',
    re_registration_start_day    int unsigned    null comment '수동 재등록 시작일(1~31)',
    re_registration_start_time   int unsigned    null comment '수동 재등록 시작시간(HH:MM:SS)',
    re_registration_end_day      int unsigned    null comment '수동 재등록 종료일(1~31)',
    re_registration_end_time     int unsigned    null comment '수동 재등록 종료시간(HH:MM:SS)',
    shard_seq                    int default 11  null,
    created_date_time            bigint unsigned not null comment '생성 일시',
    updated_date_time            bigint unsigned null comment '수정 일시',
    constraint uk_program_regular_ticket_ticket_id
        unique (ticket_id)
)
    comment '프로그램 정기이용권';

create definer = admin@`%` trigger create_program_regular_ticket_unix_timestamp_trigger
    before insert
    on program_regular_ticket
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_program_regular_ticket_unix_timestamp_trigger
    before update
                      on program_regular_ticket
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table program_ticket
(
    program_ticket_id                     int unsigned auto_increment comment '프로그램 이용권 ID'
        primary key,
    ticket_id                             int unsigned       not null comment '이용권 ID',
    ticket_type                           tinyint            not null comment '이용권 타입(1: REGULAR, 2: TEMPORARY, 3: SINGLE_USE)',
    program_ticket_type                   tinyint            not null comment '프로그램 구분(1:단체, 2:개인레슨)',
    staff_id                              int unsigned       null comment '관리자 아이디(강사 ID)',
    total_capacity                        int unsigned       null comment '전체 정원(NULL 제한없음)',
    total_available_num                   int unsigned       null comment '이용가능횟수',
    daily_available_num                   int unsigned       null comment '일 이용가능횟수',
    online_registration_method            tinyint            null comment '온라인 등록 방법 (1: PAYMENT, 2: APPLICATION, 3:OFFLINE)',
    use_target_type                       tinyint default 1  not null comment '이용대상(1: 개인, 2: 세대)',
    reception_method                      tinyint default 1  not null comment '접수방식(1: 선착순, 2: 추첨)',
    is_possible_intermediate_registration tinyint default 1  not null comment '당월 중도등록 가능여부(0: 사용안함, 1: 사용) = 상시등록가능여부',
    is_use_payment_imposition_option      tinyint default 0  not null comment '결제금액 부과옵션 사용여부(0: 사용안함, 1: 사용)',
    payment_amount_deduction_type         tinyint default 0  not null comment '결제금액 차감방식(0: 사용안함, 1: 일할계산, 2: 횟수계산)',
    is_displayed_on_kiosk                 tinyint default 1  not null comment '키오스크 표시여부(0: 사용안함, 1: 사용)',
    is_possible_duplicated_registration   tinyint default 1  not null comment '이용권 중복등록 가능여부(0: 사용안함, 1: 사용)',
    shard_seq                             int     default 11 null,
    created_date_time                     bigint unsigned    not null comment '생성 일시',
    updated_date_time                     bigint unsigned    null comment '수정 일시',
    constraint uk_program_ticket_ticket_id
        unique (ticket_id)
)
    comment '프로그램 이용권';

create definer = admin@`%` trigger create_program_ticket_unix_timestamp_trigger
    before insert
    on program_ticket
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_program_ticket_unix_timestamp_trigger
    before update
                      on program_ticket
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table program_ticket_period
(
    program_ticket_period_id    int unsigned auto_increment comment '프로그램 등록기간 ID'
        primary key,
    ticket_id                   int unsigned    not null comment '이용권 ID',
    program_ticket_id           int unsigned    not null comment '프로그램 이용권 ID',
    new_registration_start_day  int unsigned    not null comment '신규등록 시작일 (1~31)',
    new_registration_start_time int unsigned    not null comment '신규등록 시작시간(HH:MM:SS)',
    new_registration_end_day    int unsigned    not null comment '신규등록 종료일 (1~31)',
    new_registration_end_time   int unsigned    not null comment '신규등록 종료시간(HH:MM:SS)',
    draw_apply_start_date_time  bigint unsigned null comment '추첨접수 시작일시',
    draw_apply_end_date_time    bigint unsigned null comment '추첨접수 종료일시',
    draw_date_time              bigint unsigned null comment '추첨일시',
    shard_seq                   int default 11  null,
    created_date_time           bigint unsigned not null comment '생성 일시',
    updated_date_time           bigint unsigned null comment '수정 일시',
    constraint uk_program_ticket_period_ticket_id
        unique (ticket_id)
)
    comment '프로그램 등록기간';

create definer = admin@`%` trigger create_program_ticket_period_unix_timestamp_trigger
    before insert
    on program_ticket_period
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_program_ticket_period_unix_timestamp_trigger
    before update
                      on program_ticket_period
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table room_reservation
(
    room_reservation_id     int unsigned auto_increment comment '대관 예약 ID'
        primary key,
    facility_reservation_id int unsigned       not null comment '시설 예약 ID',
    use_start_date_time     bigint unsigned    not null comment '사용시작일시(YYYY-MM-DD HH:MM:SS)',
    use_end_date_time       bigint unsigned    not null comment '사용종료일시(YYYY-MM-DD HH:MM:SS)',
    reservation_date        bigint unsigned    null comment '예약일',
    start_time              int unsigned       null comment '예약 시작 시간',
    end_time                int unsigned       null comment '예약 종료 시간',
    status                  tinyint default 1  not null comment '예약 상태(0: 취소, 1: 예약)',
    guest_count             int     default 1  not null comment '예약인원',
    is_deleted              tinyint default 0  not null comment '삭제 여부(0: false, 1: true)',
    shard_seq               int     default 11 null,
    created_date_time       bigint unsigned    not null comment '생성 일시',
    updated_date_time       bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_room_reservation_unix_timestamp_trigger
    before insert
    on room_reservation
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_room_reservation_unix_timestamp_trigger
    before update
                      on room_reservation
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table room_time_restriction
(
    room_time_restriction_id int unsigned auto_increment comment '타석 타임 제한 ID'
        primary key,
    facility_id              int unsigned    not null comment '시설 ID',
    facility_timetable_id    int unsigned    not null comment '시설 타임테이블 ID',
    restriction_type         tinyint         not null comment '제한 종류(1: 사용안함, 2: 레슨중, 3: 점검중)',
    shard_seq                int default 11  null,
    created_date_time        bigint unsigned not null comment '생성일시',
    updated_date_time        bigint unsigned null comment '수정일시'
);

create definer = admin@`%` trigger create_room_time_restriction_unix_timestamp_trigger
    before insert
    on room_time_restriction
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_room_time_restriction_unix_timestamp_trigger
    before update
                      on room_time_restriction
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
end;

create table sales
(
    sales_id                 int unsigned auto_increment comment '매출 ID'
        primary key,
    apt_id                   int unsigned       null comment '아파트 ID',
    facility_type_id         int unsigned       not null,
    facility_id              int unsigned       null comment '시설 ID',
    member_id                int unsigned       null comment '입주민 ID',
    dong                     varchar(20)        not null comment '동',
    ho                       varchar(20)        not null comment '호',
    member_name              varchar(50)        not null comment '입주민 이름',
    sales_date_time          bigint unsigned    not null comment '매출일시(정산일)',
    type                     tinyint default 1  not null comment '매출 타입(1: 매출, 2: 환불)',
    status                   tinyint            not null comment '매출상태 (1: 결제, 2: 취소(부분취소))',
    platform                 tinyint            not null comment '플랫폼 (1:관리자, 2:키오스크, 3:모바일, 4:POS)',
    facility_type_name       varchar(50)        not null comment '시설 카테고리 이름',
    facility_name            varchar(50)        not null comment '시설 이름',
    sales_unit_name          varchar(50)        not null comment '상품 이름',
    display_name             varchar(50)        null comment '표시이름',
    payment_method           tinyint            null comment '상세 타입(1: 관리비, 2: 카드, 3:현금)',
    total_price              int                null comment '원가',
    total_amount             int                not null,
    total_coupon_used_count  int                null comment '쿠폰 사용 갯수',
    total_sales_amount       int unsigned       not null comment '총합계 매출금액 ( 총 매출금액 or 환불 타입 금액)',
    is_deleted               tinyint default 0  not null comment '삭제 여부',
    deleted_date_time        bigint unsigned    null,
    deleted_by               varchar(32)        null,
    last_cancelled_date_time bigint             null comment '마지막 취소일시',
    shard_seq                int     default 11 null,
    created_date_time        bigint unsigned    null,
    updated_date_time        bigint unsigned    null
);

create index idx_sales_apt_id_crated_date_time_member_id
    on sales (apt_id, created_date_time, member_id);

create definer = admin@`%` trigger sales_creation_timestamp_trigger
    before insert
    on sales
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger sales_update_timestamp_trigger
    before update
                      on sales
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table sales_detail
(
    sales_detail_id     int unsigned auto_increment comment '매출 상세 ID'
        primary key,
    sales_id            int unsigned             not null comment '매출 ID',
    ticket_id           int unsigned             null,
    item_id             int unsigned             null,
    facility_name       varchar(50)              not null comment '시설 이름',
    sales_unit_name     varchar(50)              not null comment '상품 이름',
    display_name        varchar(50)              null comment '표시이름',
    unit_price          int unsigned             not null comment '상품 판매 단가',
    item_quantity       int unsigned             not null comment '상품 이름',
    total_price         int unsigned             not null comment '총 금액 (quantity * price)',
    used_coupons        int unsigned default '0' not null comment '쿠폰 사용갯수',
    option_amount       int unsigned             null comment '옵션 합산 금액(null은 옵션없음)',
    discount_amount     int unsigned default '0' not null comment '할인금액(쿠폰 할인금액 or 관리자 할인금액 )',
    amount              int                      not null,
    status              tinyint                  not null,
    sales_amount        int                      not null comment '매출금액(결제금액 or (사용금액 + 위약금))',
    used_amount         int unsigned             null comment '사용금액 (0 ~ 결제금액)',
    penalty_fee         int unsigned             null comment '위약금',
    cancelled_date_time bigint                   null comment '취소일시',
    created_date_time   bigint unsigned          null,
    updated_date_time   bigint unsigned          null,
    shard_seq           int          default 11  null
);

create definer = admin@`%` trigger sales_detail_creation_timestamp_trigger
    before insert
    on sales_detail
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger sales_detail_update_timestamp_trigger
    before update
                      on sales_detail
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table sales_detail_history
(
    sales_detail_history_id int unsigned auto_increment comment '매출 상세 히스토리 ID'
        primary key,
    sales_detail_id         int unsigned    not null comment '매출 상세 ID',
    type                    tinyint         not null comment '히스토리 타입(1: 결제, 2: 취소, 3: 수정)',
    unit_price              int unsigned    not null comment '상품 판매 단가',
    item_quantity           int unsigned    not null comment '상품 판매 수량',
    total_price             int unsigned    not null comment '총 금액 (quantity * price)',
    used_coupons            int unsigned    not null comment '쿠폰 사용갯수',
    option_amount           int unsigned    null comment '옵션 합산 금액(null은 옵션없음)',
    amount                  int unsigned    not null comment '결제금액 (총 금액 + 옵션 합산 금액 or 쿠폰사용으로 0원 + 옵션 합산 금액 or 관리자 수정 금액)',
    status                  tinyint         not null comment '상태(1: 결제, 2: 취소)',
    sales_amount            int             not null comment '매출금액(결제금액 or (사용금액 + 위약금))',
    used_amount             int unsigned    not null comment '사용금액 (0 ~ 결제금액)',
    penalty_fee             int unsigned    not null comment '위약금',
    created_by              varchar(32)     not null comment '변경한 시스템또는 관리자',
    reason_type             tinyint         null comment '변경 사유 타입(0: 기타, 1: 전출, 2: 개인사유, 3: 서비스 불만족, 4: 사용자취소)',
    modified_reason         text            null comment '취소/삭제/수정 시 매출 변경 사유',
    platform                tinyint         not null,
    shard_seq               int default 11  null,
    created_date_time       bigint unsigned not null comment '생성 일시',
    updated_date_time       bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_sales_detail_history_unix_timestamp_trigger
    before insert
    on sales_detail_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_sales_detail_history_unix_timestamp_trigger
    before update
                      on sales_detail_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table sales_detail_option
(
    sales_detail_option_id int unsigned auto_increment
        primary key,
    sales_detail_id        int unsigned       not null,
    type                   tinyint default 4  not null comment '옵션타입(1: 이용권 이용요금, 2: 이용권 연장요금, 3: 이용권 추가부과, 4: 상품 옵션)',
    name                   varchar(50)        not null,
    value                  varchar(50)        null,
    unit_price             int unsigned       not null comment '판매 단가',
    quantity               int unsigned       not null comment '수량',
    total_price            int unsigned       not null comment '총 금액 (quantity * unit_price)',
    amount                 int unsigned       not null comment '결제금액',
    status                 tinyint default 1  not null comment '매출상세 옵션 상태(1: 결제, 2: 취소)',
    created_date_time      bigint unsigned    not null,
    updated_date_time      bigint unsigned    null,
    shard_seq              int     default 11 null
);

create definer = admin@`%` trigger create_sales_detail_option_timestamp_trigger
    before insert
    on sales_detail_option
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_sales_detail_option_timestamp_trigger
    before update
                      on sales_detail_option
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table sales_detail_option_history
(
    sales_detail_option_history_id int unsigned auto_increment comment '매출 상세 옵션 히스토리 ID'
        primary key,
    sales_detail_option_id         int unsigned    not null comment '매출 상세 옵션 ID',
    type                           tinyint         not null comment '히스토리 타입(1: 결제, 2: 취소, 3: 수정)',
    name                           varchar(50)     not null comment '옵션명',
    value                          varchar(50)     not null comment '옵션값',
    unit_price                     int unsigned    not null comment '판매 단가',
    quantity                       int unsigned    not null comment '수량',
    total_price                    int unsigned    not null comment '총 금액 (quantity * unit_price)',
    amount                         int unsigned    not null comment '결제금액',
    status                         tinyint         not null comment '매출상세 옵션 상태(1: 결제, 2: 취소)',
    shard_seq                      int default 11  null,
    created_date_time              bigint unsigned not null comment '생성 일시',
    updated_date_time              bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_sales_detail_option_history_unix_timestamp_trigger
    before insert
    on sales_detail_option_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_sales_detail_option_history_unix_timestamp_trigger
    before update
                      on sales_detail_option_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table sales_history
(
    sales_history_id         int unsigned auto_increment comment '매출 히스토리 ID'
        primary key,
    sales_id                 int unsigned    not null comment '매출 ID',
    created_by               varchar(32)     not null,
    type                     tinyint         not null,
    created_date_time        bigint unsigned not null,
    previous_amount          int             null,
    amount                   int             null,
    shard_seq                int default 11  null,
    updated_date_time        int unsigned    null,
    first_paid_amount        int             null,
    used_amount              int             null,
    penalty                  int             null,
    canceled_sales_amount    int             null,
    modified_reason          text            null,
    cancellation_reason_type tinyint         null,
    canceled_date_time       bigint unsigned null,
    previous_sales_date_time mediumtext      null,
    sales_date_time          mediumtext      null
);

create definer = admin@`%` trigger sales_history_creation_timestamp_trigger
    before insert
    on sales_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger sales_history_update_timestamp_trigger
    before update
                      on sales_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table sales_modified_history
(
    sales_modified_history_id   int unsigned auto_increment comment '매출 수정 히스토리 ID'
        primary key,
    sales_id                    int unsigned    not null comment '매출 ID',
    type                        tinyint         not null comment '수정 히스토리 타입 (1: 매출일 수정, 2: 합계 매출 금액 수정, 3: 삭제, 4: 삭제복구, 5: 환불)',
    sales_date_time             bigint unsigned null comment '매출일시',
    modified_date_time          bigint unsigned null comment '수정일시',
    total_sales_amount          int unsigned    null comment '합계 매출 금액',
    modified_total_sales_amount int unsigned    null comment '변경 후 합계 매출금액',
    created_by                  varchar(32)     not null comment '변경한 시스템또는 관리자',
    modified_reason             text            null comment '변경 사유',
    shard_seq                   int default 11  null,
    created_date_time           bigint unsigned not null comment '생성 일시',
    updated_date_time           bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_sales_modified_history_unix_timestamp_trigger
    before insert
    on sales_modified_history
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_sales_modified_history_unix_timestamp_trigger
    before update
                      on sales_modified_history
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table seat
(
    seat_id           int unsigned auto_increment comment '좌석 ID'
        primary key,
    facility_id       int unsigned       not null comment '시설 ID',
    number            smallint           not null comment '좌석 번호',
    code              smallint           null comment '좌석 점등제어기 연결 코드(1~0000)',
    is_mobile         tinyint default 0  not null comment '모바일 배정 (0:불가, 1:가능)',
    is_kiosk          tinyint default 0  not null comment '키오스크 배정 (0:불가, 1:가능)',
    gender            tinyint default 0  not null comment '이용성별(0:공통, 1:남, 2:여)',
    is_available      tinyint default 1  not null comment '사용 여부 (0: FALSE, 1: TRUE)',
    is_deleted        tinyint default 0  not null comment '삭제 여부(0: FALSE, 1: TRUE)',
    shard_seq         int     default 11 null,
    created_date_time bigint unsigned    not null comment '생성 일시',
    updated_date_time bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_seat_unix_timestamp_trigger
    before insert
    on seat
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_seat_unix_timestamp_trigger
    before update
                      on seat
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table seat_available_ticket
(
    seat_available_ticket_id int unsigned auto_increment comment '좌석 가능 이용권 ID'
        primary key,
    seat_id                  int unsigned    not null comment '좌석 ID',
    ticket_id                int unsigned    not null comment '이용권 ID',
    shard_seq                int default 11  null,
    created_date_time        bigint unsigned not null comment '생성 일시',
    updated_date_time        bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_seat_available_ticket_unix_timestamp_trigger
    before insert
    on seat_available_ticket
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_seat_available_ticket_unix_timestamp_trigger
    before update
                      on seat_available_ticket
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table seat_reservation
(
    seat_reservation_id     int unsigned auto_increment comment '좌석 예약 ID'
        primary key,
    facility_reservation_id int unsigned       not null comment '시설 예약 ID',
    seat_id                 int unsigned       not null comment '좌석 ID',
    use_start_date_time     bigint unsigned    not null comment '사용시작일시(YYYY-MM-DD HH:MM:SS)',
    use_end_date_time       bigint unsigned    not null comment '사용종료일시(YYYY-MM-DD HH:MM:SS)',
    status                  tinyint default 1  not null comment '예약 상태(0: 취소, 1: 예약)',
    is_deleted              tinyint default 0  not null comment '삭제 여부(0: false, 1: true)',
    shard_seq               int     default 11 null,
    created_date_time       bigint unsigned    not null comment '생성 일시',
    updated_date_time       bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_seat_reservation_unix_timestamp_trigger
    before insert
    on seat_reservation
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_seat_reservation_unix_timestamp_trigger
    before update
                      on seat_reservation
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table seat_sort_order
(
    seat_sort_order_id int unsigned auto_increment comment '좌석 정렬 ID'
        primary key,
    seat_id            int unsigned    not null comment '좌석 ID',
    facility_id        int unsigned    not null comment '시설 ID',
    sort_order         int unsigned    null comment '정렬 순서',
    shard_seq          int default 11  null,
    created_date_time  bigint unsigned not null comment '생성 일시',
    updated_date_time  bigint unsigned null comment '수정 일시'
);

create definer = admin@`%` trigger create_seat_sort_order_unix_timestamp_trigger
    before insert
    on seat_sort_order
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_seat_sort_order_unix_timestamp_trigger
    before update
                      on seat_sort_order
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table single_use_ticket
(
    single_use_ticket_id   int unsigned auto_increment comment '1회 이용권 ID'
        primary key,
    ticket_id              int unsigned       not null comment '이용권 ID',
    single_use_ticket_type tinyint default 1  not null comment '1회이용권 구분(1: 일반(NORMAL), 2: 할증(SURCHAGE))',
    shard_seq              int     default 11 null,
    created_date_time      bigint unsigned    not null comment '생성 일시',
    updated_date_time      bigint unsigned    null comment '수정 일시',
    constraint uk_single_use_ticket_ticket_id
        unique (ticket_id)
)
    comment '1회 이용권';

create definer = admin@`%` trigger create_single_use_ticket_unix_timestamp_trigger
    before insert
    on single_use_ticket
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_single_use_ticket_unix_timestamp_trigger
    before update
                      on single_use_ticket
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table template
(
    template_id int unsigned   null,
    column1     varchar(20)    null,
    column2     varchar(20)    null,
    shard_seq   int default 11 null
);

create table ticket
(
    ticket_id              int unsigned auto_increment comment '이용권 ID'
        primary key,
    ticket_category_id     int unsigned       not null comment '카테고리 ID',
    facility_id            int unsigned       not null comment '시설 ID',
    ticket_name            varchar(40)        not null comment '이용권 이름',
    ticket_type            tinyint            not null comment '이용권 타입(1: REGULAR, 2: TEMPORARY, 3: SINGLE_USE)',
    ticket_price           int unsigned       not null comment '이용권 요금(원)',
    num_deduction_coupons  int unsigned       null comment '커뮤니티 쿠폰차감 갯수(NULL 이면 사용안함)',
    is_limited_age         tinyint default 0  not null comment '이용권 나이제한 (0: 제한없음, 1:제한)',
    available_minimum_age  int                null comment '이용가능한 최소 나이',
    is_online_registration tinyint default 0  not null comment '온라인 등록 사용여부(0: FALSE, 1: TRUE)',
    is_available           tinyint default 1  not null comment '사용 여부(0: FALSE, 1: TRUE)',
    shard_seq              int     default 11 null,
    is_deleted             tinyint default 0  not null comment '삭제 여부(0: FALSE, 1: TRUE)',
    created_date_time      bigint unsigned    not null comment '생성 일시',
    updated_date_time      bigint unsigned    null comment '수정 일시'
)
    comment '이용권';

create index IDX_TICKET_FACILITY_ID
    on ticket (facility_id);

create index idx_ticket_facility_id_is_deleted
    on ticket (ticket_id, facility_id, is_deleted);

create definer = admin@`%` trigger create_ticket_unix_timestamp_trigger
    before insert
    on ticket
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_ticket_unix_timestamp_trigger
    before update
                      on ticket
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table ticket_category
(
    ticket_category_id int unsigned auto_increment comment '카테고리 ID'
        primary key,
    facility_id        int unsigned                            not null comment '시설 ID',
    name               varchar(100) collate utf8mb4_0900_as_cs not null comment '카테고리 명',
    is_default         tinyint default 0                       not null comment '기본값여부(0: false, 1: true)',
    shard_seq          int     default 11                      null,
    created_date_time  bigint unsigned                         not null comment '생성 일시',
    updated_date_time  bigint unsigned                         null comment '수정 일시',
    constraint UK_ticket_category
        unique (facility_id, name)
);

create definer = admin@`%` trigger create_ticket_category_unix_timestamp_trigger
    before insert
    on ticket_category
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_ticket_category_unix_timestamp_trigger
    before update
                      on ticket_category
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table ticket_detail
(
    ticket_detail_id  int unsigned auto_increment comment '이용권 상세정보 ID'
        primary key,
    ticket_id         int unsigned    not null comment '이용권 ID',
    remark            text            null comment '비고',
    shard_seq         int default 11  null,
    created_date_time bigint unsigned not null comment '생성 일시',
    updated_date_time bigint unsigned null comment '수정 일시',
    constraint ticket_id
        unique (ticket_id)
)
    comment '이용권 상세정보';

create definer = admin@`%` trigger create_ticket_detail_unix_timestamp_trigger
    before insert
    on ticket_detail
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_ticket_detail_unix_timestamp_trigger
    before update
                      on ticket_detail
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table ticket_issue
(
    ticket_issue_id         int unsigned auto_increment comment '발권 ID'
        primary key,
    ticket_own_id           int unsigned       not null comment '이용권 보유 ID',
    ticket_id               int unsigned       not null comment '이용권 ID',
    member_id               int unsigned       not null comment '입주민 ID',
    facility_reservation_id int unsigned       null comment '시설 예약 ID',
    type                    tinyint            not null comment '발권 타입(1: 이용권 보유, 2: 시설 예약 )',
    use_start_date_time     bigint unsigned    not null comment '발권사용가능시작일시',
    use_end_date_time       bigint unsigned    not null comment '발권사용가능종료일시',
    is_used                 tinyint default 0  not null comment '발권사용여부(0: false, 1: true)',
    used_date_time          bigint unsigned    null comment '발권사용일시',
    expired_use_date_time   bigint unsigned    null comment '발권사용만료일시 ( 발권사용가능종료일시 or 사용일시 + 1회 이용가능시간)',
    issue_method            tinyint            not null comment '발권 수단(1: 모바일, 2: 키오스크, 3: 관리자, 4: 게이트)',
    is_deleted              tinyint default 0  not null comment '삭제여부(0: false, 1: true)',
    shard_seq               int     default 11 null,
    created_date_time       bigint unsigned    not null comment '생성 일시',
    updated_date_time       bigint unsigned    null comment '수정 일시'
);

create index IDX_TICKET_OWN_ID
    on ticket_issue (ticket_own_id);

create index IDX_TICKET_OWN_MEMBER_DEL
    on ticket_issue (ticket_own_id, member_id, is_deleted);

create definer = admin@`%` trigger create_ticket_issue_unix_timestamp_trigger
    before insert
    on ticket_issue
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_ticket_issue_unix_timestamp_trigger
    before update
                      on ticket_issue
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table ticket_issue_detail
(
    ticket_issue_id        int unsigned       not null comment '발권 ID'
        primary key,
    handkey_number         varchar(20)        null comment '핸드키번호',
    electronic_key_number  int unsigned       null comment '전자키번호',
    batter_box_seat_number smallint           null comment '좌/타석 번호',
    reference_number       smallint           null comment '좌/타석/사물함 번호',
    is_deleted             tinyint default 0  not null comment '삭제여부(0: false, 1: true)',
    shard_seq              int     default 11 null,
    created_date_time      bigint unsigned    not null comment '생성 일시',
    updated_date_time      bigint unsigned    null comment '수정 일시'
);

create definer = admin@`%` trigger create_ticket_issue_detail_unix_timestamp_trigger
    before insert
    on ticket_issue_detail
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_ticket_issue_detail_unix_timestamp_trigger
    before update
                      on ticket_issue_detail
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table ticket_own
(
    ticket_own_id                int unsigned auto_increment comment '이용권 보유 ID'
        primary key,
    ticket_id                    int unsigned       not null comment '이용권 ID',
    member_id                    int unsigned       not null comment '입주민 ID',
    sales_id                     int unsigned       not null comment '매출 ID',
    sales_detail_id              int unsigned       null comment '매출 상세 ID - 이용권',
    start_date                   bigint unsigned    not null comment '이용 시작 날짜(예: 2024-01-01 00:00:00 의 unixtimestamp)',
    end_date                     bigint unsigned    not null comment '이용 종료 날짜(예: 2024-01-01 00:00:00 의 unixtimestamp)',
    weekdays                     int unsigned       null comment '이용요일(bit 연산)',
    start_time                   int unsigned       not null comment '이용권 시작 시간(예: 00:00:00)',
    end_time                     int unsigned       not null comment '이용권 종료 시간(예: 00:00:00)',
    total_available_num          int unsigned       null comment '이용가능횟수',
    daily_available_num          int unsigned       null comment '일 이용가능횟수',
    is_available_re_registration tinyint default 1  not null comment '재등록 가능 여부(0: false, 1: true)',
    use_target_type              tinyint default 1  not null comment '이용대상(1: 개인, 2: 세대)',
    registration_type            tinyint default 1  not null comment '등록 타입(1: 신규, 2: 재등록)',
    status                       tinyint default 1  not null comment '보유상태 (0: 전체취소, 1: 사용, 2: 부분취소)',
    canceled_date_time           bigint unsigned    null comment '취소일시',
    next_ticket_own_id           int unsigned       null comment '다음 재등록 이용권 보유 ID',
    platform                     tinyint            not null comment '플랫폼(1: 관리자, 2: 키오스크, 3: 모바일, 4: 포스)',
    is_deleted                   tinyint default 0  not null comment '삭제여부(0: false, 1: true)',
    shard_seq                    int     default 11 null,
    created_date_time            bigint unsigned    not null comment '생성 일시',
    updated_date_time            bigint unsigned    null comment '수정 일시'
);

create index idx_perf
    on ticket_own (member_id asc, is_deleted asc, created_date_time desc);

create definer = admin@`%` trigger create_ticket_own_unix_timestamp_trigger
    before insert
    on ticket_own
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_ticket_own_unix_timestamp_trigger
    before update
                      on ticket_own
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create table ticket_usage_period
(
    ticket_usage_period_id int unsigned auto_increment comment '이용권 이용일시 ID'
        primary key,
    ticket_id              int unsigned    not null comment '이용권 ID',
    start_date             bigint unsigned null comment '이용권 시작 날짜(예: 2024-01-01 00:00:00 의 unixtimestamp)',
    end_date               bigint unsigned null comment '이용권 종료 날짜(예: 2024-01-01 00:00:00 의 unixtimestamp)',
    weekdays               int unsigned    null comment '이용권 이용요일(bit 연산 값)',
    start_time             int unsigned    null comment '이용권 시작 시간(예: 00:00:00)',
    end_time               int unsigned    null comment '이용권 종료 시간(예: 00:00:00)',
    shard_seq              int default 11  null,
    created_date_time      bigint unsigned not null comment '생성 일시',
    updated_date_time      bigint unsigned null comment '수정 일시',
    constraint ticket_id
        unique (ticket_id)
)
    comment '이용권 이용일시';

create index idx_ticket_usage_period_start_date_end_date
    on ticket_usage_period (start_date, end_date);

create index idx_usage_period_date
    on ticket_usage_period (ticket_id, start_date, end_date);

create definer = admin@`%` trigger create_ticket_usage_period_unix_timestamp_trigger
    before insert
    on ticket_usage_period
    for each row
BEGIN
    SET NEW.created_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

create definer = admin@`%` trigger update_ticket_usage_period_unix_timestamp_trigger
    before update
                      on ticket_usage_period
                      for each row
BEGIN
    SET NEW.updated_date_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
END;

