Creator.odata = {}
Creator.odata.get = (object_name, record_id, select_fields, callback)->
	result = null
	isAsync = callback and _.isFunction(callback)
	spaceId = Steedos.spaceId()
	unless spaceId
		return
	if object_name and record_id
		url = Steedos.absoluteUrl "/api/odata/v4/#{spaceId}/#{object_name}/#{record_id}"
		request_data = {}
		if select_fields
			request_data = 
				"$select": select_fields
		$.ajax
			type: "get"
			url: url
			data: request_data
			dataType: "json"
			contentType: "application/json"
			async: !!isAsync
			beforeSend: (request) ->
				request.setRequestHeader('X-User-Id', Meteor.userId())
				request.setRequestHeader('X-Auth-Token', Accounts._storedLoginToken())
			success: (data) ->
				result = data
				if isAsync
					callback(result)
			error: (jqXHR, textStatus, errorThrown) ->
				error = jqXHR.responseJSON.error
				# if error.httpStatus == 400 or error.httpStatus == 401
				# 	message = t("creator_odata_authentication_required")
				# else if error.httpStatus == 403
				# 	message =t("creator_odata_user_access_fail")
				# else if error.httpStatus == 404
				# 	message =t("creator_odata_record_query_fail")
				# else if error.httpStatus == 500
				if error?.reason
					toastr?.error?(TAPi18n.__(error.reason))
				else if error?.message
					#toastr?.error?(TAPi18n.__(error.message))
					toastr.error(t(error?.message))
				else
					toastr?.error?("未找到记录")
				if isAsync
					callback(false, error)
				
	else
		toastr.error("未找到记录")
	return result

Creator.odata.query = (object_name, options, is_ajax, callback)->
	result = null
	spaceId = Steedos.spaceId()
	unless spaceId
		return
	isAsync = callback and _.isFunction(callback)
	if is_ajax
		if object_name
			url = Steedos.absoluteUrl "/api/odata/v4/#{spaceId}/#{object_name}"
			$.ajax
				type: "get"
				url: url
				data:options
				dataType: "json"
				async: !!isAsync
				contentType: "application/json"
				beforeSend: (request) ->
					request.setRequestHeader('X-User-Id', Meteor.userId())
					request.setRequestHeader('X-Auth-Token', Accounts._storedLoginToken())
				error: (jqXHR, textStatus, errorThrown) ->
					error = jqXHR.responseJSON
					console.error error
					if error.reason
						toastr?.error?(TAPi18n.__(error.reason))
					else if error.message
						toastr?.error?(TAPi18n.__(error.message))
					else
						toastr?.error?(error)
					if isAsync
						callback(false, error)
				success:(data) ->
					result = data.value
					if isAsync
						callback(result)
		return result
	else
		if object_name
			url = Steedos.absoluteUrl "/api/odata/v4/#{spaceId}/#{object_name}"
			store = new DevExpress.data.ODataStore({
				type: "odata"
				version: 4
				url: url
				beforeSend: (request) ->
					request.headers['X-User-Id'] = Meteor.userId()
					request.headers['X-Space-Id'] = Steedos.spaceId()
					request.headers['X-Auth-Token'] = Accounts._storedLoginToken()
			})
			options.store = store
			datasource = new DevExpress.data.DataSource(options)
			datasource.load()
				.done((result) ->
					console.log result
				)
				.fail((error) ->
					console.log error
					if error.reason
						toastr?.error?(TAPi18n.__(error.reason))
					else if error.message
						toastr?.error?(TAPi18n.__(error.message))
					else
						toastr?.error?(error)
				)
	
	# 	$.ajax
	# 		type: "get"
	# 		url: url
	# 		data:selector
	# 		dataType: "json"
	# 		contentType: "application/json"
	# 		beforeSend: (request) ->
	# 			request.setRequestHeader('X-User-Id', Meteor.userId())
	# 			request.setRequestHeader('X-Auth-Token', Accounts._storedLoginToken())
	# 		error: (jqXHR, textStatus, errorThrown) ->
	# 			error = jqXHR.responseJSON
	# 			console.error error
	# 			if error.reason
	# 				toastr?.error?(TAPi18n.__(error.reason))
	# 			else if error.message
	# 				toastr?.error?(TAPi18n.__(error.message))
	# 			else
	# 				toastr?.error?(error)
	# else
	# 	toastr.error("未找到记录")				

Creator.odata.delete = (object_name,record_id,callback)->
	spaceId = Steedos.spaceId()
	unless spaceId
		return
	if object_name and record_id
		url = Steedos.absoluteUrl "/api/odata/v4/#{spaceId}/#{object_name}/#{record_id}"
		$.ajax
			type: "delete"
			url: url
			dataType: "json"
			contentType: "application/json"
			beforeSend: (request) ->
				request.setRequestHeader('X-User-Id', Meteor.userId())
				request.setRequestHeader('X-Auth-Token', Accounts._storedLoginToken())

			success: (data) ->
				if callback and typeof callback == "function"
					callback()
				else
					toastr?.success?(t("afModal_remove_suc"))

			error: (jqXHR, textStatus, errorThrown) ->
				error = jqXHR.responseJSON.error
				console.error error
				if error.reason
					if error.details
						toastr?.error?(TAPi18n.__(error.reason, error.details))
					else
		 				toastr?.error?(TAPi18n.__(error.reason))
				else if error.message
					toastr?.error?(TAPi18n.__(error.message))
				else
					toastr?.error?(error)

Creator.odata.update = (object_name,record_id,doc,callback)->
	spaceId = Steedos.spaceId()
	unless spaceId
		return
	if object_name and record_id
		url = Steedos.absoluteUrl "/api/odata/v4/#{spaceId}/#{object_name}/#{record_id}"
		data = {}
		data['$set'] = doc
		$.ajax
			type: "put"
			url: url
			data: JSON.stringify(data)
			dataType: 'json'
			contentType: "application/json"
			processData: false
			beforeSend: (request) ->
				request.setRequestHeader('X-User-Id', Meteor.userId())
				request.setRequestHeader('X-Auth-Token', Accounts._storedLoginToken())

			success: (data) ->
				if callback and typeof callback == "function"
					callback()
				# else
				# 	toastr?.success?(t("afModal_remove_suc"))

			error: (jqXHR, textStatus, errorThrown) ->
				error = jqXHR.responseJSON.error
				console.error error
				if error.reason
					toastr?.error?(TAPi18n.__(error.reason))
				else if error.message
					toastr?.error?(TAPi18n.__(error.message))
				else
					toastr?.error?(error)
Creator.odata.insert = (object_name,doc)->
	spaceId = Steedos.spaceId()
	unless spaceId
		return
	if object_name
		url = Steedos.absoluteUrl "/api/odata/v4/#{spaceId}/#{object_name}"
		$.ajax
			type: "post"
			url: url
			data: JSON.stringify(doc)
			dataType: 'json'
			contentType: "application/json"
			processData: false
			beforeSend: (request) ->
				request.setRequestHeader('X-User-Id', Meteor.userId())
				request.setRequestHeader('X-Auth-Token', Accounts._storedLoginToken())

			# success: (data) ->
			# 	if callback and typeof callback == "function"
			# 		callback()
			# 	else
			# 		toastr?.success?(t("afModal_remove_suc"))

			error: (jqXHR, textStatus, errorThrown) ->
				error = jqXHR.responseJSON.error
				console.error error
				if error.reason
					toastr?.error?(TAPi18n.__(error.reason))
				else if error.message
					toastr?.error?(TAPi18n.__(error.message))
				else
					toastr?.error?(error)