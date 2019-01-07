Creator.Objects.project_issues =
	name: "project_issues"
	label: "问题"
	icon: "location"
	enable_files: true
	enable_search: true
	enable_tasks: true
	fields:
		name:
			label: '标题'
			type: 'text'
			is_wide: true
			required: true

		description: 
			label: '问题描述'
			type: 'textarea'
			is_wide: true
			rows: 8

		category:
			label: '分类'
			type: 'master_detail'
			reference_to: 'projects'
			required: true

		state:
			label: "进度"
			type: "select"
			options: [
				{label:"待确认", value:"pending_confirm"}, 
				{label:"处理中", value:"in_progress"}, 
				{label:"暂停", value:"paused"}, 
				{label: "已完成", value:"completed"}
				{label: "已取消", value:"cancelled"}
			]
			sortable: true
			required: true

		priority:
			label: '优先级'
			type: "select"
			options: [
				{label:"高", value:"high"}, 
				{label:"中", value:"medium"}, 
				{label:"低", value:"low"}
			]

		status:
			label: "状态"
			type: "select"
			options: [
				{label:"进行中", value:"open"}, 
				{label:"已关闭", value:"closed"}
			]
			defaultValue: "open"

	list_views:
		open:
			label: "进行中"
			columns: ["name", "category", "created", "state", "priority"]
			filter_scope: "space"
			filters: [["status", "=", "open"]]
		closed:
			label: "已关闭"
			columns: ["name", "category", "created", "state", "priority"]
			filter_scope: "space"
			filters: [["status", "=", "closed"]]
		all:
			label: "所有"
			columns: ["name", "category", "created", "state", "priority"]
			filter_scope: "space"


	permission_set:
		user:
			allowCreate: true
			allowDelete: true
			allowEdit: true
			allowRead: true
			modifyAllRecords: false
			viewAllRecords: true
		admin:
			allowCreate: true
			allowDelete: true
			allowEdit: true
			allowRead: true
			modifyAllRecords: true
			viewAllRecords: true