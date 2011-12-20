-- ##bc平台的 postgresql 建表脚本##

-- 创建Identity用的序列，开始于1000
CREATE sequence CORE_SEQUENCE
    minvalue 1
    start with 1000
    increment by 1
    cache 20;

-- 创建序列，开始于1千万，方便历史数据的转换
CREATE sequence HIBERNATE_SEQUENCE
    minvalue 1
    start with 10000000
    increment by 1
    cache 20;

-- 测试用的表
CREATE TABLE BC_EXAMPLE (
    ID INTEGER NOT NULL,
    NAME varchar(255) NOT NULL,
    CODE varchar(255),
    PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_EXAMPLE IS '测试用的表';
COMMENT ON COLUMN BC_EXAMPLE.NAME IS '名称';

-- 系统标识相关模块
-- 系统资源
CREATE TABLE BC_IDENTITY_RESOURCE (
    ID INTEGER NOT NULL,
    UID_ varchar(36),
    TYPE_ int  DEFAULT 0 NOT NULL,
    STATUS_ int  DEFAULT 0 NOT NULL,
    INNER_ boolean NOT NULL default false,
    BELONG integer,
    ORDER_ varchar(100),
    NAME varchar(255) NOT NULL,
    URL varchar(255),
    ICONCLASS varchar(255),
    OPTION_ varchar(4000),
    PNAME varchar(4000),
    CONSTRAINT BCPK_RESOURCE PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_IDENTITY_RESOURCE IS '系统资源';
COMMENT ON COLUMN BC_IDENTITY_RESOURCE.TYPE_ IS '类型：1-文件夹,2-内部链接,3-外部链接,4-html';
COMMENT ON COLUMN BC_IDENTITY_RESOURCE.STATUS_ IS '状态：0-启用中,1-已禁用,2-已删除';
COMMENT ON COLUMN BC_IDENTITY_RESOURCE.INNER_ IS '是否为内置对象:0-否,1-是';
COMMENT ON COLUMN BC_IDENTITY_RESOURCE.BELONG IS '所隶属的资源';
COMMENT ON COLUMN BC_IDENTITY_RESOURCE.ORDER_ IS '排序号';
COMMENT ON COLUMN BC_IDENTITY_RESOURCE.NAME IS '名称';
COMMENT ON COLUMN BC_IDENTITY_RESOURCE.URL IS '地址';
COMMENT ON COLUMN BC_IDENTITY_RESOURCE.ICONCLASS IS '图标样式';
COMMENT ON COLUMN BC_IDENTITY_RESOURCE.OPTION_ IS '扩展参数';
COMMENT ON COLUMN BC_IDENTITY_RESOURCE.PNAME IS '所隶属模块的全名:如系统维护/组织架构/单位配置';
CREATE INDEX BCIDX_RESOURCE_BELONG ON BC_IDENTITY_RESOURCE (BELONG);
CREATE INDEX BCIDX_RESOURCE_BELONG_NULL ON BC_IDENTITY_RESOURCE (COALESCE(BELONG,0));

-- 角色
CREATE TABLE BC_IDENTITY_ROLE (
    ID INTEGER NOT NULL,
    CODE varchar(100) NOT NULL,
    ORDER_ varchar(100),
    NAME varchar(255) NOT NULL,
    UID_ varchar(36),
    TYPE_ int  NOT NULL,
    STATUS_ int  NOT NULL,
    INNER_ boolean NOT NULL default false,
    CONSTRAINT BCPK_ROLE PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_IDENTITY_ROLE IS '角色';
COMMENT ON COLUMN BC_IDENTITY_ROLE.CODE IS '编码';
COMMENT ON COLUMN BC_IDENTITY_ROLE.ORDER_ IS '排序号';
COMMENT ON COLUMN BC_IDENTITY_ROLE.NAME IS '名称';
COMMENT ON COLUMN BC_IDENTITY_ROLE.TYPE_ IS '类型';
COMMENT ON COLUMN BC_IDENTITY_ROLE.STATUS_ IS '状态：0-启用中,1-已禁用,2-已删除';
COMMENT ON COLUMN BC_IDENTITY_ROLE.INNER_ IS '是否为内置对象:0-否,1-是';

-- 角色与资源的关联
CREATE TABLE BC_IDENTITY_ROLE_RESOURCE (
    RID integer NOT NULL,
    SID integer NOT NULL,
    CONSTRAINT BCPK_ROLE_RESOURCE PRIMARY KEY (RID,SID)
);
COMMENT ON TABLE BC_IDENTITY_ROLE_RESOURCE IS '角色与资源的关联：角色可以访问哪些资源';
COMMENT ON COLUMN BC_IDENTITY_ROLE_RESOURCE.RID IS '角色ID';
COMMENT ON COLUMN BC_IDENTITY_ROLE_RESOURCE.SID IS '资源ID';
ALTER TABLE BC_IDENTITY_ROLE_RESOURCE ADD CONSTRAINT BCFK_RS_ROLE FOREIGN KEY (RID) REFERENCES BC_IDENTITY_ROLE (ID);
ALTER TABLE BC_IDENTITY_ROLE_RESOURCE ADD CONSTRAINT BCFK_RS_RESOURCE FOREIGN KEY (SID) REFERENCES BC_IDENTITY_RESOURCE (ID);

-- 职务
CREATE TABLE BC_IDENTITY_DUTY (
    ID INTEGER NOT NULL,
    CODE varchar(100) NOT NULL,
    NAME varchar(255) NOT NULL,
    CONSTRAINT BCPK_DUTY PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_IDENTITY_DUTY IS '职务';
COMMENT ON COLUMN BC_IDENTITY_DUTY.CODE IS '编码';
COMMENT ON COLUMN BC_IDENTITY_DUTY.NAME IS '名称';

-- 参与者的扩展属性
CREATE TABLE BC_IDENTITY_ACTOR_DETAIL (
    ID INTEGER NOT NULL,
    CREATE_DATE timestamp,
    WORK_DATE timestamp,
    ISO boolean NOT NULL default false,
    SEX int  default 0,
    CARD varchar(20),
    DUTY_ID integer,
    COMMENT_ varchar(4000),
    CONSTRAINT BCPK_ACTOR_DETAIL PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_IDENTITY_ACTOR_DETAIL IS '参与者的扩展属性';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_DETAIL.CREATE_DATE IS '创建时间';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_DETAIL.WORK_DATE IS 'user-入职时间';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_DETAIL.SEX IS 'user-性别：0-未设置,1-男,2-女';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_DETAIL.DUTY_ID IS 'user-职务ID';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_DETAIL.COMMENT_ IS '备注';
ALTER TABLE BC_IDENTITY_ACTOR_DETAIL ADD CONSTRAINT BCFK_ACTORDETAIL_DUTY FOREIGN KEY (DUTY_ID) REFERENCES BC_IDENTITY_DUTY (ID);

-- 参与者
CREATE TABLE BC_IDENTITY_ACTOR (
    ID INTEGER NOT NULL,
    UID_ varchar(36) NOT NULL,
    TYPE_ int  DEFAULT 0 NOT NULL,
    STATUS_ int  DEFAULT 0 NOT NULL,
    INNER_ boolean NOT NULL default false,
    CODE varchar(100) NOT NULL,
    NAME varchar(255) NOT NULL,
    PY varchar(255),
    ORDER_ varchar(100),
    EMAIL varchar(255),
    PHONE varchar(255),
    DETAIL_ID integer,
    PCODE varchar(4000),
    PNAME varchar(4000),
    CONSTRAINT BCPK_ACTOR PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_IDENTITY_ACTOR IS '参与者(代表一个人或组织，组织也可以是单位、部门、岗位、团队等)';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.UID_ IS '全局标识';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.TYPE_ IS '类型：0-未定义,1-单位,2-部门,3-岗位,4-用户';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.STATUS_ IS '状态：0-启用中,1-已禁用,2-已删除';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.INNER_ IS '是否为内置对象:0-否,1-是';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.CODE IS '编码';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.NAME IS '名称';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.PY IS '名称的拼音';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.ORDER_ IS '同类参与者之间的排序号';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.EMAIL IS '邮箱';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.PHONE IS '联系电话';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.DETAIL_ID IS '扩展表的ID';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.PCODE IS '隶属机构的全编码';
COMMENT ON COLUMN BC_IDENTITY_ACTOR.PNAME IS '隶属机构的全名';
ALTER TABLE BC_IDENTITY_ACTOR ADD CONSTRAINT BCFK_ACTOR_ACTORDETAIL FOREIGN KEY (DETAIL_ID) 
	REFERENCES BC_IDENTITY_ACTOR_DETAIL (ID) ON DELETE CASCADE;
CREATE INDEX BCIDX_ACTOR_CODE ON BC_IDENTITY_ACTOR (CODE ASC);
CREATE INDEX BCIDX_ACTOR_NAME ON BC_IDENTITY_ACTOR (NAME ASC);
CREATE INDEX BCIDX_ACTOR_STATUSTYPE ON BC_IDENTITY_ACTOR (STATUS_ ASC,TYPE_ ASC);
CREATE INDEX BCIDX_ACTOR_TYPE ON BC_IDENTITY_ACTOR (TYPE_ ASC);
CREATE INDEX BCIDX_ACTOR_DETAIL ON BC_IDENTITY_ACTOR (DETAIL_ID ASC);

-- 参与者之间的关联关系
CREATE TABLE BC_IDENTITY_ACTOR_RELATION (
    TYPE_ integer NOT NULL,
    MASTER_ID integer NOT NULL,
    FOLLOWER_ID integer NOT NULL,
    ORDER_ varchar(100),
    CONSTRAINT BCPK_ACTOR_RELATION PRIMARY KEY (MASTER_ID,FOLLOWER_ID,TYPE_)
);
COMMENT ON TABLE BC_IDENTITY_ACTOR_RELATION IS '参与者之间的关联关系';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_RELATION.TYPE_ IS '关联类型';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_RELATION.MASTER_ID IS '主控方ID';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_RELATION.FOLLOWER_ID IS '从属方ID';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_RELATION.ORDER_ IS '从属方之间的排序号';
ALTER TABLE BC_IDENTITY_ACTOR_RELATION ADD CONSTRAINT BCFK_AR_MASTER FOREIGN KEY (MASTER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_IDENTITY_ACTOR_RELATION ADD CONSTRAINT BCFK_AR_FOLLOWER FOREIGN KEY (FOLLOWER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
CREATE INDEX BCIDX_AR_TM ON BC_IDENTITY_ACTOR_RELATION (TYPE_, MASTER_ID);
CREATE INDEX BCIDX_AR_TF ON BC_IDENTITY_ACTOR_RELATION (TYPE_, FOLLOWER_ID);

-- ACTOR隶属信息的变动历史
CREATE TABLE BC_IDENTITY_ACTOR_HISTORY (
   ID                   INTEGER           NOT NULL,
   PID                  integer,
   CURRENT              integer NOT NULL DEFAULT 1,
   RANK              	integer NOT NULL DEFAULT 0,
   CREATE_DATE          timestamp                 NOT NULL,
   START_DATE           timestamp,
   END_DATE             timestamp,
   ACTOR_TYPE           int            NOT NULL,
   ACTOR_ID             integer           NOT NULL,
   ACTOR_NAME           varchar(100)        NOT NULL,
   UPPER_ID             integer,
   UPPER_NAME           varchar(255),
   UNIT_ID              integer,
   UNIT_NAME            varchar(255),
   PCODE varchar(4000),
   PNAME varchar(4000),
   CONSTRAINT BCPK_ACTOR_HISTORY PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_IDENTITY_ACTOR_HISTORY IS 'ACTOR隶属信息的变动历史';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.PID IS '对应旧记录的id';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.CURRENT IS '是否为当前配置';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.RANK IS '多个当前配置间的首选次序，数值越小级别越高，值从0开始递增，只适用于隶属多个组织的情况';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.CREATE_DATE IS '创建时间';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.START_DATE IS '起始时段';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.END_DATE IS '结束时段';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.ACTOR_TYPE IS 'ACTOR类型';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.ACTOR_ID IS 'ACTORID';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.ACTOR_NAME IS 'ACTOR名称';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.UPPER_ID IS '直属上级ID';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.UPPER_NAME IS '直属上级名称';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.UNIT_ID IS '所在单位ID';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.UNIT_NAME IS '所在单位名称';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.PCODE IS '隶属机构的全编码';
COMMENT ON COLUMN BC_IDENTITY_ACTOR_HISTORY.PNAME IS '隶属机构的全名';
ALTER TABLE BC_IDENTITY_ACTOR_HISTORY ADD CONSTRAINT BCFK_ACTORHISTORY_PID FOREIGN KEY (PID) 
	REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
ALTER TABLE BC_IDENTITY_ACTOR_HISTORY ADD CONSTRAINT BCFK_ACTORHISTORY_ACTOR FOREIGN KEY (ACTOR_ID)
      REFERENCES BC_IDENTITY_ACTOR (ID);
CREATE INDEX BCIDX_ACTORHISTORY_ACTORID ON BC_IDENTITY_ACTOR_HISTORY (ACTOR_ID ASC);
CREATE INDEX BCIDX_ACTORHISTORY_ACTORNAME ON BC_IDENTITY_ACTOR_HISTORY (ACTOR_NAME ASC);
CREATE INDEX BCIDX_ACTORHISTORY_UPPER ON BC_IDENTITY_ACTOR_HISTORY (UPPER_ID ASC);
CREATE INDEX BCIDX_ACTORHISTORY_UNIT ON BC_IDENTITY_ACTOR_HISTORY (UNIT_ID ASC);

-- 认证信息
CREATE TABLE BC_IDENTITY_AUTH (
    ID integer NOT NULL,
    PASSWORD varchar(32) NOT NULL,
    CONSTRAINT BCPK_AUTH PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_IDENTITY_AUTH IS '认证信息';
COMMENT ON COLUMN BC_IDENTITY_AUTH.ID IS '与Actor表的id对应';
COMMENT ON COLUMN BC_IDENTITY_AUTH.PASSWORD IS '经MD5加密的密码';
ALTER TABLE BC_IDENTITY_AUTH ADD CONSTRAINT BCFK_AUTH_ACTOR FOREIGN KEY (ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);

-- 标识生成器
CREATE TABLE BC_IDENTITY_IDGENERATOR (
  TYPE_ varchar(45) NOT NULL,
  VALUE_ integer NOT NULL,
  FORMAT varchar(45) ,
  CONSTRAINT BCPK_IDGENERATOR PRIMARY KEY (TYPE_)
);
COMMENT ON TABLE BC_IDENTITY_IDGENERATOR IS '标识生成器,用于生成主键或唯一编码用';
COMMENT ON COLUMN BC_IDENTITY_IDGENERATOR.TYPE_ IS '分类';
COMMENT ON COLUMN BC_IDENTITY_IDGENERATOR.VALUE_ IS '当前值';
COMMENT ON COLUMN BC_IDENTITY_IDGENERATOR.FORMAT IS '格式模板,如“case-${V}”、“${T}-${V}”,V代表value的值，T代表type_的值';

-- 参与者与角色的关联
CREATE TABLE BC_IDENTITY_ROLE_ACTOR (
    AID integer NOT NULL,
    RID integer NOT NULL,
    CONSTRAINT BCPK_ROLE_ACTOR PRIMARY KEY (AID,RID)
);
ALTER TABLE BC_IDENTITY_ROLE_ACTOR ADD CONSTRAINT BCFK_RA_ACTOR FOREIGN KEY (AID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_IDENTITY_ROLE_ACTOR ADD CONSTRAINT BCFK_RA_ROLE FOREIGN KEY (RID) 
	REFERENCES BC_IDENTITY_ROLE (ID);
COMMENT ON TABLE BC_IDENTITY_ROLE_ACTOR IS '参与者与角色的关联：参与者拥有哪些角色';
COMMENT ON COLUMN BC_IDENTITY_ROLE_ACTOR.AID IS '参与者ID';
COMMENT ON COLUMN BC_IDENTITY_ROLE_ACTOR.RID IS '角色ID';
	
-- ##系统桌面相关模块##
-- 桌面快捷方式
create table BC_DESKTOP_SHORTCUT (
    ID INTEGER NOT NULL,
    UID_ varchar(36),
    STATUS_ int NOT NULL,
    INNER_ boolean NOT NULL default false,
    ORDER_ varchar(100) NOT NULL,
    STANDALONE boolean NOT NULL default false,
    NAME varchar(255),
    URL varchar(255),
    ICONCLASS varchar(255),
    SID integer default 0 NOT NULL,
    AID integer default 0 NOT NULL,
    CONSTRAINT BCPK_DESKTOP_SHORTCUT primary key (ID)
);
COMMENT ON TABLE BC_DESKTOP_SHORTCUT IS '桌面快捷方式';
COMMENT ON COLUMN BC_DESKTOP_SHORTCUT.UID_ IS '全局标识';
COMMENT ON COLUMN BC_DESKTOP_SHORTCUT.STATUS_ IS '状态：0-启用中,1-已禁用,2-已删除';
COMMENT ON COLUMN BC_DESKTOP_SHORTCUT.INNER_ IS '是否为内置对象:0-否,1-是';
COMMENT ON COLUMN BC_DESKTOP_SHORTCUT.STANDALONE IS '是否在独立的浏览器窗口中打开';
COMMENT ON COLUMN BC_DESKTOP_SHORTCUT.NAME IS '名称,为空则使用模块的名称';
COMMENT ON COLUMN BC_DESKTOP_SHORTCUT.URL IS '地址,为空则使用模块的地址';
COMMENT ON COLUMN BC_DESKTOP_SHORTCUT.ICONCLASS IS '图标样式';
COMMENT ON COLUMN BC_DESKTOP_SHORTCUT.SID IS '对应的资源ID';
COMMENT ON COLUMN BC_DESKTOP_SHORTCUT.AID IS '所属的参与者(如果为上级参与者,如单位部门,则其下的所有参与者都拥有该快捷方式)';
CREATE INDEX BCIDX_SHORTCUT ON BC_DESKTOP_SHORTCUT (AID,SID);

-- 个人设置
CREATE TABLE BC_DESKTOP_PERSONAL (
    ID INTEGER NOT NULL,
    UID_ varchar(36),
    STATUS_ int  NOT NULL,
    FONT varchar(2) NOT NULL,
    THEME varchar(255) NOT NULL,
    AID integer default 0 NOT NULL,
    INNER_ boolean NOT NULL default false,
    CONSTRAINT BCPK_DESKTOP_PERSONAL PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_DESKTOP_PERSONAL IS '个人设置';
COMMENT ON COLUMN BC_DESKTOP_PERSONAL.UID_ IS '全局标识';
COMMENT ON COLUMN BC_DESKTOP_PERSONAL.STATUS_ IS '状态：0-启用中,1-已禁用,2-已删除';
COMMENT ON COLUMN BC_DESKTOP_PERSONAL.FONT IS '字体大小，如12、14、16';
COMMENT ON COLUMN BC_DESKTOP_PERSONAL.THEME IS '主题名称,如base';
COMMENT ON COLUMN BC_DESKTOP_PERSONAL.AID IS '所属的参与者';
COMMENT ON COLUMN BC_DESKTOP_PERSONAL.INNER_ IS '是否为内置对象:0-否,1-是';
ALTER TABLE BC_DESKTOP_PERSONAL ADD CONSTRAINT BCUK_PERSONAL_AID UNIQUE (AID);

-- 消息模块
CREATE TABLE BC_MESSAGE (
    ID INTEGER NOT NULL,
    UID_ varchar(36),
    STATUS_ int default 0 NOT NULL,
    TYPE_ int default 0 NOT NULL,
    SENDER_ID integer NOT NULL,
    SEND_DATE timestamp NOT NULL,
    RECEIVER_ID integer NOT NULL,
    READ_ int default 0 NOT NULL,
    FROM_ID integer,
    FROM_TYPE integer,
    SUBJECT varchar(255) NOT NULL,
    CONTENT varchar(4000),
    CONSTRAINT BCPK_MESSAGE PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_MESSAGE IS '消息模块';
COMMENT ON COLUMN BC_MESSAGE.STATUS_ IS '状态：0-发送中,1-已发送,2-已删除,3-发送失败';
COMMENT ON COLUMN BC_MESSAGE.TYPE_ IS '消息类型';
COMMENT ON COLUMN BC_MESSAGE.SENDER_ID IS '发送者';
COMMENT ON COLUMN BC_MESSAGE.SEND_DATE IS '发送时间';
COMMENT ON COLUMN BC_MESSAGE.RECEIVER_ID IS '接收者';
COMMENT ON COLUMN BC_MESSAGE.FROM_ID IS '来源标识';
COMMENT ON COLUMN BC_MESSAGE.FROM_TYPE IS '来源类型';
COMMENT ON COLUMN BC_MESSAGE.READ_ IS '已阅标记';
COMMENT ON COLUMN BC_MESSAGE.SUBJECT IS '标题';
COMMENT ON COLUMN BC_MESSAGE.CONTENT IS '内容';
ALTER TABLE BC_MESSAGE ADD CONSTRAINT BCFK_MESSAGE_SENDER FOREIGN KEY (SENDER_ID) 
	REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
ALTER TABLE BC_MESSAGE ADD CONSTRAINT BCFK_MESSAGE_REVEIVER FOREIGN KEY (RECEIVER_ID) 
	REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
CREATE INDEX BCIDX_MESSAGE_FROMID ON BC_MESSAGE (FROM_TYPE,FROM_ID);
CREATE INDEX BCIDX_MESSAGE_TYPE ON BC_MESSAGE (TYPE_);

-- 工作事项
CREATE TABLE BC_WORK (
    ID INTEGER NOT NULL,
    CLASSIFIER varchar(500) NOT NULL,
    SUBJECT varchar(255) NOT NULL,
    FROM_ID integer,
    FROM_TYPE integer,
    FROM_INFO varchar(255),
    OPEN_URL varchar(255),
    CONTENT varchar(4000),
    CONSTRAINT BCPK_WORK PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_WORK IS '工作事项';
COMMENT ON COLUMN BC_WORK.CLASSIFIER IS '分类词,可多级分类,级间使用/连接,如“发文类/正式发文”';
COMMENT ON COLUMN BC_WORK.SUBJECT IS '标题';
COMMENT ON COLUMN BC_WORK.FROM_ID IS '来源标识';
COMMENT ON COLUMN BC_WORK.FROM_TYPE IS '来源类型';
COMMENT ON COLUMN BC_WORK.FROM_INFO IS '来源描述';
COMMENT ON COLUMN BC_WORK.OPEN_URL IS '打开的Url模板';
COMMENT ON COLUMN BC_WORK.CONTENT IS '内容';
CREATE INDEX BCIDX_WORK_FROM ON BC_WORK (FROM_TYPE,FROM_ID);

-- 待办事项
CREATE TABLE BC_WORK_TODO (
    ID INTEGER NOT NULL,
    WORK_ID integer NOT NULL,
    SENDER_ID integer NOT NULL,
    SEND_DATE timestamp NOT NULL,
    WORKER_ID integer NOT NULL,
    INFO varchar(255),
    CONSTRAINT BCPK_WORK_TODO PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_WORK_TODO IS '待办事项';
COMMENT ON COLUMN BC_WORK_TODO.WORK_ID IS '工作事项ID';
COMMENT ON COLUMN BC_WORK_TODO.SENDER_ID IS '发送者';
COMMENT ON COLUMN BC_WORK_TODO.SEND_DATE IS '发送时间';
COMMENT ON COLUMN BC_WORK_TODO.WORKER_ID IS '发送者';
COMMENT ON COLUMN BC_WORK_TODO.INFO IS '附加说明';
ALTER TABLE BC_WORK_TODO ADD CONSTRAINT BCFK_TODOWORK_WORK FOREIGN KEY (WORK_ID) 
	REFERENCES BC_WORK (ID);
ALTER TABLE BC_WORK_TODO ADD CONSTRAINT BCFK_TODOWORK_SENDER FOREIGN KEY (SENDER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_WORK_TODO ADD CONSTRAINT BCFK_TODOWORK_WORKER FOREIGN KEY (WORKER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);

-- 已办事项
CREATE TABLE BC_WORK_DONE (
    ID INTEGER NOT NULL,
    FINISH_DATE timestamp NOT NULL,
    FINISH_YEAR integer  NOT NULL,
    FINISH_MONTH integer  NOT NULL,
    FINISH_DAY integer  NOT NULL,
    WORK_ID integer NOT NULL,
    SENDER_ID integer NOT NULL,
    SEND_DATE timestamp NOT NULL,
    WORKER_ID integer NOT NULL,
    INFO varchar(255),
    CONSTRAINT BCPK_WORK_DONE PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_WORK_DONE IS '已办事项';
COMMENT ON COLUMN BC_WORK_DONE.FINISH_DATE IS '完成时间';
COMMENT ON COLUMN BC_WORK_DONE.FINISH_YEAR IS '完成时间的年度';
COMMENT ON COLUMN BC_WORK_DONE.FINISH_MONTH IS '完成时间的月份(1-12)';
COMMENT ON COLUMN BC_WORK_DONE.FINISH_DAY IS '完成时间的日(1-31)';
COMMENT ON COLUMN BC_WORK_DONE.WORK_ID IS '工作事项ID';
COMMENT ON COLUMN BC_WORK_DONE.SENDER_ID IS '发送者';
COMMENT ON COLUMN BC_WORK_DONE.SEND_DATE IS '发送时间';
COMMENT ON COLUMN BC_WORK_DONE.WORKER_ID IS '发送者';
COMMENT ON COLUMN BC_WORK_DONE.INFO IS '附加说明';
ALTER TABLE BC_WORK_DONE ADD CONSTRAINT BCFK_DONEWORK_WORK FOREIGN KEY (WORK_ID) 
	REFERENCES BC_WORK (ID);
ALTER TABLE BC_WORK_DONE ADD CONSTRAINT BCFK_DONEWORK_SENDER FOREIGN KEY (SENDER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_WORK_DONE ADD CONSTRAINT BCFK_DONEWORK_WORKER FOREIGN KEY (WORKER_ID) 
	REFERENCES BC_IDENTITY_ACTOR (ID);
CREATE INDEX BCIDX_DONEWORK_FINISHtimestamp ON BC_WORK_DONE (FINISH_YEAR,FINISH_MONTH,FINISH_DAY);


-- 系统日志
CREATE TABLE BC_LOG_SYSTEM (
    ID INTEGER NOT NULL,
    TYPE_ int  NOT NULL,
    SUBJECT varchar(500) NOT NULL,
    FILE_DATE timestamp NOT NULL,
    AUTHOR_ID integer NOT NULL,
    C_IP varchar(100),
    C_NAME varchar(100),
    C_INFO varchar(1000),
    S_IP varchar(100),
    S_NAME varchar(100),
    S_INFO varchar(1000),
    CONTENT varchar(4000),
    CONSTRAINT BCPK_LOG_SYSTEM PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_LOG_SYSTEM IS '系统日志';
COMMENT ON COLUMN BC_LOG_SYSTEM.TYPE_ IS '类别：0-登录,1-注销,2-超时';
COMMENT ON COLUMN BC_LOG_SYSTEM.FILE_DATE IS '创建时间';
COMMENT ON COLUMN BC_LOG_SYSTEM.SUBJECT IS '标题';
COMMENT ON COLUMN BC_LOG_SYSTEM.AUTHOR_ID IS '创建人ID';
COMMENT ON COLUMN BC_LOG_SYSTEM.C_IP IS '用户机器IP';
COMMENT ON COLUMN BC_LOG_SYSTEM.C_NAME IS '用户机器名称';
COMMENT ON COLUMN BC_LOG_SYSTEM.C_INFO IS '用户浏览器信息：User-Agent';
COMMENT ON COLUMN BC_LOG_SYSTEM.S_IP IS '服务器IP';
COMMENT ON COLUMN BC_LOG_SYSTEM.S_NAME IS '服务器名称';
COMMENT ON COLUMN BC_LOG_SYSTEM.S_INFO IS '服务器信息';
COMMENT ON COLUMN BC_LOG_SYSTEM.CONTENT IS '详细内容';
ALTER TABLE BC_LOG_SYSTEM ADD CONSTRAINT BCFK_SYSLOG_USER FOREIGN KEY (AUTHOR_ID) 
	REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
CREATE INDEX BCIDX_SYSLOG_CLIENT ON BC_LOG_SYSTEM (C_IP);
CREATE INDEX BCIDX_SYSLOG_SERVER ON BC_LOG_SYSTEM (S_IP);


-- 公告模块
CREATE TABLE BC_BULLETIN (
    ID INTEGER NOT NULL,
    UID_ varchar(36) NOT NULL,
    UNIT_ID integer,
    SCOPE int  NOT NULL,
    STATUS_ int  NOT NULL,
    OVERDUE_DATE timestamp,
    ISSUE_DATE timestamp,
    ISSUER_ID integer,
    SUBJECT varchar(500) NOT NULL,
    FILE_DATE timestamp NOT NULL,
    AUTHOR_ID integer NOT NULL,
    MODIFIER_ID integer,
    MODIFIED_DATE timestamp,
    CONTENT varchar(4000) NOT NULL,
    CONSTRAINT BCPK_BULLETIN PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_BULLETIN IS '公告模块';
COMMENT ON COLUMN BC_BULLETIN.UID_ IS '关联附件的标识号';
COMMENT ON COLUMN BC_BULLETIN.UNIT_ID IS '公告所属单位ID';
COMMENT ON COLUMN BC_BULLETIN.SCOPE IS '公告发布范围：0-本单位,1-全系统';
COMMENT ON COLUMN BC_BULLETIN.STATUS_ IS '状态:0-草稿,1-已发布,2-已过期';
COMMENT ON COLUMN BC_BULLETIN.OVERDUE_DATE IS '过期日期：为空代表永不过期';
COMMENT ON COLUMN BC_BULLETIN.ISSUE_DATE IS '发布时间';
COMMENT ON COLUMN BC_BULLETIN.ISSUER_ID IS '发布人ID';
COMMENT ON COLUMN BC_BULLETIN.SUBJECT IS '标题';
COMMENT ON COLUMN BC_BULLETIN.FILE_DATE IS '创建时间';
COMMENT ON COLUMN BC_BULLETIN.AUTHOR_ID IS '创建人ID';
COMMENT ON COLUMN BC_BULLETIN.MODIFIER_ID IS '最后修改人ID';
COMMENT ON COLUMN BC_BULLETIN.MODIFIED_DATE IS '最后修改时间';
COMMENT ON COLUMN BC_BULLETIN.CONTENT IS '详细内容';
ALTER TABLE BC_BULLETIN ADD CONSTRAINT BCFK_BULLETIN_AUTHOR FOREIGN KEY (AUTHOR_ID)
      REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
ALTER TABLE BC_BULLETIN ADD CONSTRAINT BCFK_BULLETIN_ISSUER FOREIGN KEY (ISSUER_ID)
      REFERENCES BC_IDENTITY_ACTOR (ID);
ALTER TABLE BC_BULLETIN ADD CONSTRAINT BCFK_BULLETIN_MODIFIER FOREIGN KEY (MODIFIER_ID)
      REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
ALTER TABLE BC_BULLETIN ADD CONSTRAINT BCFK_BULLETIN_UNIT FOREIGN KEY (UNIT_ID)
      REFERENCES BC_IDENTITY_ACTOR (ID);
CREATE INDEX BCIDX_BULLETIN_SEARCH ON BC_BULLETIN (SCOPE,UNIT_ID,STATUS_);

-- 文档附件
CREATE TABLE BC_DOCS_ATTACH (
    ID INTEGER NOT NULL,
    STATUS_ int  NOT NULL,
    PTYPE varchar(36) NOT NULL,
    PUID varchar(36) NOT NULL,
    SIZE_ integer NOT NULL,
    COUNT_ integer default 0 NOT NULL,
    EXT varchar(10),
    APPPATH boolean NOT NULL default false,
    SUBJECT varchar(500) NOT NULL,
    PATH varchar(500) NOT NULL,
    FILE_DATE timestamp NOT NULL,
    AUTHOR_ID integer NOT NULL,
    MODIFIER_ID integer,
    MODIFIED_DATE timestamp,
    CONSTRAINT BCPK_ATTACH PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_DOCS_ATTACH IS '文档附件,记录文档与其相关附件之间的关系';
COMMENT ON COLUMN BC_DOCS_ATTACH.STATUS_ IS '状态：0-启用中,1-已禁用,2-已删除';
COMMENT ON COLUMN BC_DOCS_ATTACH.PTYPE IS '所关联文档的类型';
COMMENT ON COLUMN BC_DOCS_ATTACH.PUID IS '所关联文档的UID';
COMMENT ON COLUMN BC_DOCS_ATTACH.SIZE_ IS '文件的大小(单位为字节)';
COMMENT ON COLUMN BC_DOCS_ATTACH.COUNT_ IS '文件的下载次数';
COMMENT ON COLUMN BC_DOCS_ATTACH.EXT IS '文件扩展名：如png、doc、mp3等';
COMMENT ON COLUMN BC_DOCS_ATTACH.APPPATH IS '指定path的值是相对于应用部署目录下路径还是相对于全局配置的app.data目录下的路径';
COMMENT ON COLUMN BC_DOCS_ATTACH.SUBJECT IS '文件名称(不带路径的部分)';
COMMENT ON COLUMN BC_DOCS_ATTACH.PATH IS '物理文件保存的相对路径(相对于全局配置的附件根目录下的子路径，如"2011/bulletin/xxxx.doc")';

COMMENT ON COLUMN BC_DOCS_ATTACH.FILE_DATE IS '创建时间';
COMMENT ON COLUMN BC_DOCS_ATTACH.AUTHOR_ID IS '创建人ID';
COMMENT ON COLUMN BC_DOCS_ATTACH.MODIFIER_ID IS '最后修改人ID';
COMMENT ON COLUMN BC_DOCS_ATTACH.MODIFIED_DATE IS '最后修改时间';
ALTER TABLE BC_DOCS_ATTACH ADD CONSTRAINT BCFK_ATTACH_AUTHOR FOREIGN KEY (AUTHOR_ID) 
	REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
ALTER TABLE BC_DOCS_ATTACH ADD CONSTRAINT BCFK_ATTACH_MODIFIER FOREIGN KEY (MODIFIER_ID) 
	REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
CREATE INDEX BCIDX_ATTACH_PUID ON BC_DOCS_ATTACH (PUID);
CREATE INDEX BCIDX_ATTACH_PTYPE ON BC_DOCS_ATTACH (PTYPE);

-- 附件处理痕迹
CREATE TABLE BC_DOCS_ATTACH_HISTORY (
    ID INTEGER NOT NULL,
    AID integer NOT NULL,
    TYPE_ integer NOT NULL,
    SUBJECT varchar(500) NOT NULL,
    FORMAT varchar(10),
    FILE_DATE timestamp NOT NULL,
    AUTHOR_ID integer NOT NULL,
    MODIFIER_ID integer,
    MODIFIED_DATE timestamp,
    C_IP varchar(100),
    C_INFO varchar(1000),
    MEMO varchar(2000),
    CONSTRAINT BCPK_ATTACH_HISTORY PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_DOCS_ATTACH_HISTORY IS '附件处理痕迹';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.AID IS '附件ID';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.TYPE_ IS '处理类型：0-下载,1-在线查看,2-格式转换';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.SUBJECT IS '简单说明';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.FORMAT IS '下载的文件格式或转换后的文件格式：如pdf、doc、mp3等';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.C_IP IS '客户端IP';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.C_INFO IS '浏览器信息：User-Agent';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.MEMO IS '备注';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.FILE_DATE IS '处理时间';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.AUTHOR_ID IS '创建人ID';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.MODIFIER_ID IS '最后修改人ID';
COMMENT ON COLUMN BC_DOCS_ATTACH_HISTORY.MODIFIED_DATE IS '最后修改时间';
ALTER TABLE BC_DOCS_ATTACH_HISTORY ADD CONSTRAINT BCFK_ATTACHHISTORY_AUTHOR FOREIGN KEY (AUTHOR_ID) 
	REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
ALTER TABLE BC_DOCS_ATTACH_HISTORY ADD CONSTRAINT BCFK_ATTACHHISTORY_MODIFIER FOREIGN KEY (MODIFIER_ID) 
	REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
ALTER TABLE BC_DOCS_ATTACH_HISTORY ADD CONSTRAINT BCFK_ATTACHHISTORY_ATTACH FOREIGN KEY (AID) 
	REFERENCES BC_DOCS_ATTACH (ID);

-- 用户反馈
CREATE TABLE BC_FEEDBACK (
    ID INTEGER NOT NULL,
    UID_ varchar(36) NOT NULL,
    STATUS_ int  NOT NULL,
    SUBJECT varchar(500) NOT NULL,
    FILE_DATE timestamp NOT NULL,
    AUTHOR_ID integer NOT NULL,
    MODIFIER_ID integer,
    MODIFIED_DATE timestamp,
    CONTENT varchar(4000) NOT NULL,
    CONSTRAINT BCPK_FEEDBACK PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_FEEDBACK IS '用户反馈';
COMMENT ON COLUMN BC_FEEDBACK.UID_ IS '关联附件的标识号';
COMMENT ON COLUMN BC_FEEDBACK.STATUS_ IS '状态:0-草稿,1-已提交,2-已受理';
COMMENT ON COLUMN BC_FEEDBACK.FILE_DATE IS '创建时间';
COMMENT ON COLUMN BC_FEEDBACK.SUBJECT IS '标题';
COMMENT ON COLUMN BC_FEEDBACK.CONTENT IS '详细内容';
COMMENT ON COLUMN BC_FEEDBACK.AUTHOR_ID IS '创建人ID';
COMMENT ON COLUMN BC_FEEDBACK.MODIFIER_ID IS '最后修改人ID';
COMMENT ON COLUMN BC_FEEDBACK.MODIFIED_DATE IS '最后修改时间';
ALTER TABLE BC_FEEDBACK ADD CONSTRAINT BCFK_FEEDBACK_AUTHOR FOREIGN KEY (AUTHOR_ID) 
	REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
ALTER TABLE BC_FEEDBACK ADD CONSTRAINT BCFK_FEEDBACK_MODIFIER FOREIGN KEY (MODIFIER_ID) 
	REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);


-- ##选项模块##
-- 选项分组
CREATE TABLE BC_OPTION_GROUP (
    ID INTEGER NOT NULL,
    KEY_ varchar(255) NOT NULL,
    VALUE_ varchar(255) NOT NULL,
    ORDER_ varchar(100),
    ICON varchar(100),
    CONSTRAINT BCPK_OPTION_GROUP PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_OPTION_GROUP IS '选项分组';
COMMENT ON COLUMN BC_OPTION_GROUP.KEY_ IS '键';
COMMENT ON COLUMN BC_OPTION_GROUP.VALUE_ IS '值';
COMMENT ON COLUMN BC_OPTION_GROUP.ORDER_ IS '排序号';
COMMENT ON COLUMN BC_OPTION_GROUP.ICON IS '图标样式';
CREATE INDEX BCIDX_OPTIONGROUP_KEY ON BC_OPTION_GROUP (KEY_);
CREATE INDEX BCIDX_OPTIONGROUP_VALUE ON BC_OPTION_GROUP (VALUE_);

-- 选项条目
CREATE TABLE BC_OPTION_ITEM (
    ID INTEGER NOT NULL,
    PID integer NOT NULL,
    KEY_ varchar(255) NOT NULL,
    VALUE_ varchar(255) NOT NULL,
    ORDER_ varchar(100),
    ICON varchar(100),
    STATUS_ int  NOT NULL,
    DESC_ varchar(1000),
    CONSTRAINT BCPK_OPTION_ITEM PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_OPTION_ITEM IS '选项条目';
COMMENT ON COLUMN BC_OPTION_ITEM.PID IS '所属分组的ID';
COMMENT ON COLUMN BC_OPTION_ITEM.KEY_ IS '键';
COMMENT ON COLUMN BC_OPTION_ITEM.VALUE_ IS '值';
COMMENT ON COLUMN BC_OPTION_ITEM.ORDER_ IS '排序号';
COMMENT ON COLUMN BC_OPTION_ITEM.ICON IS '图标样式';
COMMENT ON COLUMN BC_OPTION_ITEM.STATUS_ IS '状态：0-启用中,1-已禁用,2-已删除';
COMMENT ON COLUMN BC_OPTION_ITEM.DESC_ IS '说明';
ALTER TABLE BC_OPTION_ITEM ADD CONSTRAINT BCFK_OPTIONITEM_OPTIONGROUP FOREIGN KEY (PID) 
	REFERENCES BC_OPTION_GROUP (ID);
CREATE INDEX BCIDX_OPTIONITEM_KEY ON BC_OPTION_ITEM (KEY_);
CREATE INDEX BCIDX_OPTIONITEM_VALUE ON BC_OPTION_ITEM (VALUE_);
CREATE INDEX BCIDX_OPTIONITEM_PID ON BC_OPTION_ITEM (PID);

-- 调度任务配置
CREATE TABLE BC_SD_JOB (
    ID INTEGER NOT NULL,
    STATUS_ int  NOT NULL,
    NAME varchar(255) NOT NULL,
    GROUPN varchar(255) NOT NULL,
    CRON varchar(255) NOT NULL,
    BEAN varchar(255) NOT NULL,
    METHOD varchar(255) NOT NULL,
    IGNORE_ERROR int NOT NULL,
    ORDER_ varchar(100),
    NEXT_DATE timestamp,
    MEMO_ varchar(1000),
    CONSTRAINT BCPK_SD_JOB PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_SD_JOB IS '调度任务配置';
COMMENT ON COLUMN BC_SD_JOB.NAME IS '名称';
COMMENT ON COLUMN BC_SD_JOB.BEAN IS '要调用的SpringBean名';
COMMENT ON COLUMN BC_SD_JOB.METHOD IS '要调用的SpringBean方法名';
COMMENT ON COLUMN BC_SD_JOB.IGNORE_ERROR IS '发现异常是否忽略后继续调度:0-否,1-是';
COMMENT ON COLUMN BC_SD_JOB.MEMO_ IS '备注';
COMMENT ON COLUMN BC_SD_JOB.STATUS_ IS '状态：0-启用中,1-已禁用,2-已删除,3-正在运行,4-暂停';
COMMENT ON COLUMN BC_SD_JOB.GROUPN IS '分组名';
COMMENT ON COLUMN BC_SD_JOB.CRON IS '表达式';
COMMENT ON COLUMN BC_SD_JOB.ORDER_ IS '排序号';
COMMENT ON COLUMN BC_SD_JOB.NEXT_DATE IS '任务的下一运行时间';

-- 任务调度日志
CREATE TABLE BC_SD_LOG (
    ID INTEGER NOT NULL,
    SUCCESS int  NOT NULL,
    START_DATE timestamp NOT NULL,
    END_DATE timestamp NOT NULL,
    CFG_CRON varchar(255) NOT NULL,
    CFG_NAME varchar(255),
    CFG_GROUP varchar(255),
    CFG_BEAN varchar(255),
    CFG_METHOD varchar(255),
    ERROR_TYPE varchar(255),
    MSG text,
    CONSTRAINT BCPK_SD_LOG PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_SD_LOG IS '任务调度日志';
COMMENT ON COLUMN BC_SD_LOG.SUCCESS IS '任务是否处理成功:0-失败,1-成功';
COMMENT ON COLUMN BC_SD_LOG.START_DATE IS '任务的启动时间';
COMMENT ON COLUMN BC_SD_LOG.END_DATE IS '任务的结束时间';
COMMENT ON COLUMN BC_SD_LOG.ERROR_TYPE IS '异常分类';
COMMENT ON COLUMN BC_SD_LOG.MSG IS '异常信息';
COMMENT ON COLUMN BC_SD_LOG.CFG_CRON IS '对应ScheduleJob的cron';
COMMENT ON COLUMN BC_SD_LOG.CFG_NAME IS '对应ScheduleJob的name';
COMMENT ON COLUMN BC_SD_LOG.CFG_GROUP IS '对应ScheduleJob的groupn';
COMMENT ON COLUMN BC_SD_LOG.CFG_BEAN IS '对应ScheduleJob的bean';
COMMENT ON COLUMN BC_SD_LOG.CFG_METHOD IS '对应ScheduleJob的method';

-- 同步信息基表
CREATE TABLE BC_SYNC_BASE (
    ID INTEGER NOT NULL,
    STATUS_ int default 0 NOT NULL,
    SYNC_TYPE varchar(255) NOT NULL,
    SYNC_CODE varchar(255) NOT NULL,
    SYNC_FROM varchar(1000) NOT NULL,
    SYNC_DATE timestamp NOT NULL,
    AUTHOR_ID integer NOT NULL,
    CONSTRAINT BCPK_SYNC_BASE PRIMARY KEY (ID)
);
COMMENT ON TABLE BC_SYNC_BASE IS '同步信息基表';
COMMENT ON COLUMN BC_SYNC_BASE.STATUS_ IS '状态:0-同步后待处理,1-已处理';
COMMENT ON COLUMN BC_SYNC_BASE.SYNC_TYPE IS '同步信息的类型';
COMMENT ON COLUMN BC_SYNC_BASE.SYNC_CODE IS '同步信息的标识符';
COMMENT ON COLUMN BC_SYNC_BASE.SYNC_FROM IS '同步信息的来源';
COMMENT ON COLUMN BC_SYNC_BASE.SYNC_DATE IS '同步时间';
COMMENT ON COLUMN BC_SYNC_BASE.AUTHOR_ID IS '同步人ID';
ALTER TABLE BC_SYNC_BASE ADD CONSTRAINT BCFK_SYNC_AUTHOR FOREIGN KEY (AUTHOR_ID)
      REFERENCES BC_IDENTITY_ACTOR_HISTORY (ID);
ALTER TABLE BC_SYNC_BASE ADD CONSTRAINT BCUK_SYNC_ID UNIQUE (SYNC_TYPE,SYNC_CODE);

-- ##bc平台的 postgresql 自定义函数和存储过程##

-- 创建更新actor的pcode和pname的存储过程：会递归处理下级单位和部门
--	pid: actor所隶属上级的id，为0代表顶层单位
CREATE OR REPLACE FUNCTION update_actor_pcodepname(pid IN integer) RETURNS integer AS $$
DECLARE
	--定义变量
	pfcode varchar(4000);
	pfname varchar(4000);
	t integer := 0;
	child RECORD;
BEGIN
  	if pid > 0 then
		select (case when pcode is null then '' else pcode || '/' end) || '[' || type_ || ']' || code
        	,(case when pname is null then '' else pname || '/' end) || name
        	into pfcode,pfname from bc_identity_actor where id=pid;

		FOR child IN select a.id id,a.type_ type_ from bc_identity_actor a inner join bc_identity_actor_relation r on r.follower_id = a.id 
		where r.type_=0 and r.master_id=pid order by a.order_ LOOP
			update bc_identity_actor a set pcode=pfcode,pname=pfname where a.id=child.id;
			if child.type_ < 3 then 
				-- 单位或部门执行递归处理
				t := t + update_actor_pcodepname(child.id);
			end if;
		END LOOP;
	else
		FOR child IN select a.id id from bc_identity_actor a where a.type_=1 and not exists 
		(select r.follower_id from bc_identity_actor_relation r where r.type_=0 and a.id=r.follower_id)
	    order by a.order_ LOOP
			t := t + update_actor_pcodepname(child.id);
		END LOOP;
  	end if; 
	return t;
END;
$$ LANGUAGE plpgsql;


-- 创建更新resource的pname的存储过程：会递归处理下级资源
--	pid:resource所隶属的id，为0代表顶层资源
CREATE OR REPLACE FUNCTION update_resource_pname(pid IN integer) RETURNS integer AS $$
DECLARE
	--定义变量
	pfname varchar(4000);
	t integer := 0;
	child RECORD;
BEGIN
  	if pid > 0 then
		select (case when pname is null then '' else pname || '/' end) || name
        	into pfname from bc_identity_resource where id=pid;

		FOR child IN select r.id id,r.type_ type_ from bc_identity_resource r where r.belong = pid order by r.order_ LOOP
			update bc_identity_resource set pname=pfname where id=child.id;
			if child.type_ = 1 then 
				-- 分类型资源执行递归处理
				t := t + update_resource_pname(child.id);
			end if;
		END LOOP;
	else
		FOR child IN select r.id id from bc_identity_resource r where COALESCE(r.belong,0) = 0 order by r.order_ LOOP
			t := t + update_resource_pname(child.id);
		END LOOP;
  	end if; 
	return t;
END;
$$ LANGUAGE plpgsql;
