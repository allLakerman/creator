Creator.Objects.vip_share =
	name: "vip_share"
	label: "分享"
	icon: "omni_supervisor"
	fields:
		name:
			label:'分享人'
			type:'text'
			#owner.name
		#分享人就是owner
		related_to:
			label: "关联到"
			type: "lookup"
			reference_to: ['vip_product']
		way:
			label:'分享方式'
			type:'text'
			#可能取值[分享给好友weixin，分享至朋友圈friend_circle]
	list_views:
		all:
			label: "所有"
			columns: ["name", "related_to","created"]
			filter_scope: "space"
	permission_set:
		user:
			allowCreate: true
			allowDelete: true
			allowEdit: false
			allowRead: true
			modifyAllRecords: false
			viewAllRecords: false
		admin:
			allowCreate: true
			allowDelete: true
			allowEdit: true
			allowRead: true
			modifyAllRecords: true
			viewAllRecords: true
		member:
			allowCreate: true
			allowDelete: true
			allowEdit: false
			allowRead: true
			modifyAllRecords: false
			viewAllRecords: false
		guest:
			allowCreate: true
			allowDelete: true
			allowEdit: false
			allowRead: true
			modifyAllRecords: false
			viewAllRecords: false

		

		