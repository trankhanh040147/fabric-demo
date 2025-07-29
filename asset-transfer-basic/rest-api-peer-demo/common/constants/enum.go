package constants

const (
	AuthenticateResponseTypeCode = "code"
)

const (
	AuthenticateIdpScopeOpenId          = "openid"
	AuthenticateIdpScopeProfile         = "profile"
	AuthenticateIdpScopeContactList     = "contact.list"
	AuthenticateIdpScopeContactGet      = "contact.get"
	AuthenticateIdpScopeContactGetBatch = "contact.get_batch"
)

const (
	MemberRoleUnknown = iota
	MemberRoleOwner
	MemberRoleMember
	MemberRoleWaitingApprove
)

const (
	StatusTypeUnknown = iota
	StatusTypeTodo
	StatusTypeInProcess
	StatusTypeDone
)

var MapStatusType = map[int]struct{}{
	StatusTypeTodo:      {},
	StatusTypeInProcess: {},
	StatusTypeDone:      {},
}

var JoinedMemberRoles = []int{MemberRoleMember, MemberRoleOwner}

const TimeFormatDateOnly = "2006/01/02"

const (
	KafkaProjectMessageTypeDelete = iota + 1
	KafkaProjectMessageTypeDeleteLabel
	KafkaProjectMessageTypeUpdateLabel
	KafkaProjectMessageTypeUpdateStatus
	KafkaProjectMessageTypeUpdatePriority
)

const (
	KafkaMemberMessageTypeDelete = iota + 1
	KafkaMemberMessageTypeAcceptInvite
	KafkaMemberMessageTypeDeclineInvite
)

const (
	KafkaTaskMessageTypeDelete = iota + 1
	KafkaTaskMessageTypeCloneTask
)

const (
	KafkaAttachmentMessageTypeCreate = iota + 1
)

const (
	ContactRelationStatusUnknown = iota - 2
	ContactRelationStatusWaitingResponse
	ContactRelationStatusWaitingAccept
	ContactRelationStatusAccepted
	ContactRelationStatusDeclined
	ContactRelationStatusBlocked
)

const (
	KafkaNotifyTypeTaskUpdateTitle = iota + 1
	KafkaNotifyTypeMemberAcceptInvite
	KafkaNotifyTypeTaskCreate
	KafkaNotifyTypeMemberInvite
	KafkaNotifyTypeTaskUpdateEndedAt
	KafkaNotifyTypeTaskUpdatePriority
	KafkaNotifyTypeTaskAddAssignee
	KafkaNotifyTypeTaskUpdateStartedAt
	KafkaNotifyTypeTaskClone
	KafkaNotifyTypeTaskUpdateReporter
	KafkaNotifyTypeTaskUpdateStatus
	KafkaNotifyTypeTaskUpdateDescription
	KafkaNotifyTypeTaskUpdateLabel
	KafkaNotifyTypeAttachmentCreate
	KafkaNotifyTypeCommentCreate
	KafkaNotifyTypeInviteJoin
	KafkaNotifyTypeInviteApprove
	KafkaNotifyTypeCommentUpdate
	KafkaNotifyTypeTaskDelete
	KafkaNotifyTypeCommentDelete
	KafkaNotifyTypeTaskAddFollower
)

const (
	WebhookEventTypeUnknown = iota
	WebhookEventTypeTaskCreate
	WebhookEventTypeTaskUpdate
	WebhookEventTypeTaskDelete
	WebhookEventTypeCommentCreate
	WebhookEventTypeCommentUpdate
	WebhookEventTypeCommentDelete
)

const (
	KafkaUserMessageTypeUpdate = iota + 1
)

const (
	ActivityActionTypeUnknown = iota
	ActivityActionTypeProjectCreated
	ActivityActionTypeProjectUpdated
	ActivityActionTypeTaskCreated
	ActivityActionTypeTaskUpdated
	ActivityActionTypeCommentCreated
	ActivityActionTypeMemberAdded
	ActivityActionTypeAttachmentUploaded
	ActivityActionTypeTaskDeleted
)

const (
	ActivityChangelogProjectUpdateFieldName     = "name"
	ActivityChangelogTaskUpdateFieldTitle       = "title"
	ActivityChangelogTaskUpdateFieldDescription = "description"
	ActivityChangelogTaskUpdateFieldPriority    = "priority"
	ActivityChangelogTaskUpdateFieldEndedAt     = "ended_at"
	ActivityChangelogTaskUpdateFieldAssignee    = "assignees"
	ActivityChangelogTaskUpdateFieldStatus      = "status"
	ActivityChangelogMemberAddField             = "member"
	ActivityChangelogTaskUpdateFieldFollower    = "followers"
)

type ProjectPermission = string

const (
	PermissionTaskView                                     ProjectPermission = "task_view"
	PermissionTaskCreate                                   ProjectPermission = "task_create"
	PermissionTaskClone                                    ProjectPermission = "task_clone"
	PermissionTaskAddAssignee                              ProjectPermission = "task_add_assignee"
	PermissionTaskUpdateReporter                           ProjectPermission = "task_update_reporter"
	PermissionTaskAssignToMe                               ProjectPermission = "task_assign_to_me"
	PermissionTaskDeleteAssignee                           ProjectPermission = "task_delete_assignee"
	PermissionTaskUpdateTitle                              ProjectPermission = "task_update_title"
	PermissionTaskUpdateDescription                        ProjectPermission = "task_update_description"
	PermissionTaskUpdateColor                              ProjectPermission = "task_update_color"
	PermissionTaskUpdateStatus                             ProjectPermission = "task_update_status"
	PermissionTaskUpdatePriority                           ProjectPermission = "task_update_priority"
	PermissionTaskUpdateEndedAtDescriptionAttachmentUpload ProjectPermission = "task_update_ended_at_description_attachment_upload"
	PermissionTaskUpdateStartedAt                          ProjectPermission = "task_update_started_at"
	PermissionTaskUpdateEndedAt                            ProjectPermission = "task_update_ended_at"
	PermissionTaskUpdateFollower                           ProjectPermission = "task_update_follower"
	PermissionTaskAddFollower                              ProjectPermission = "task_add_follower"
	PermissionTaskDeleteFollower                           ProjectPermission = "task_delete_follower"
	PermissionTaskUpdateLabel                              ProjectPermission = "task_update_label"
	PermissionTaskDelete                                   ProjectPermission = "task_delete"
	PermissionTaskViewActivity                             ProjectPermission = "task_view_activity"
	PermissionAttachmentUpload                             ProjectPermission = "attachment_upload"
	PermissionCommentCreate                                ProjectPermission = "comment_create"
	PermissionMemberAdd                                    ProjectPermission = "member_add"
	PermissionMemberRemove                                 ProjectPermission = "member_remove"
	PermissionConfigUpdate                                 ProjectPermission = "config_update"
	PermissionProjectUpdate                                ProjectPermission = "project_update"
)

const (
	ProjectPolicyRoleAssignee = iota + 1
	ProjectPolicyRoleReporter
	ProjectPolicyRoleWatcher
	ProjectPolicyRoleMember
)
