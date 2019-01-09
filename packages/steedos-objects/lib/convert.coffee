Meteor.startup ()->
	getOption = (option)->
		foo = option.split(":")
		if foo.length > 1
			return {label: foo[0], value: foo[1]}
		else
			return {label: foo[0], value: foo[0]}

	Creator.convertObject = (object)->
		_.forEach object.triggers, (trigger, key)->

			if (Meteor.isServer && trigger.on == "server") || (Meteor.isClient && trigger.on == "client")
				_todo_from_code = trigger?._todo
				_todo_from_db = trigger.todo
				if _todo_from_code && _.isString(_todo_from_code)
					trigger.todo = Creator.eval("(#{_todo_from_code})")

				if _todo_from_db && _.isString(_todo_from_db)
					#只有update时， fieldNames, modifier, options 才有值
					#TODO 控制可使用的变量，尤其是Collection
					if _todo_from_db.startsWith("function")
						trigger.todo = Creator.eval("(#{_todo_from_db})")
					else
						trigger.todo = Creator.eval("(function(userId, doc, fieldNames, modifier, options){#{_todo_from_db}})")

			if Meteor.isServer && trigger.on == "client"
				_todo = trigger.todo
				if _todo && _.isFunction(_todo)
					trigger._todo = _todo.toString()

		if Meteor.isClient
			_.forEach object.actions, (action, key)->
				_todo_from_code = action?._todo
				_todo_from_db = action?.todo
				if _todo_from_code && _.isString(_todo_from_code)
					#TODO 控制可使用的变量
					try
						action.todo = Creator.eval("(#{_todo_from_code})")
					catch error
						console.error "todo_from_code", _todo_from_code
				if _todo_from_db && _.isString(_todo_from_db)
					#TODO 控制可使用的变量
					try
						if _todo_from_db.startsWith("function")
							action.todo = Creator.eval("(#{_todo_from_db})")
						else
							action.todo = Creator.eval("(function(){#{_todo_from_db}})")
					catch error
						console.error "todo_from_db", _todo_from_db, error

				_visible = action?._visible
				if _visible
					try
						action.visible = Creator.eval("(#{_visible})")
					catch error
						console.error "action.visible to function error: ", error, _visible
		else
			_.forEach object.actions, (action, key)->
				_todo = action?.todo
				if _todo && _.isFunction(_todo)
					#TODO 控制可使用的变量
					action._todo = _todo.toString()

				_visible = action?.visible

				if _visible && _.isFunction(_visible)
					action._visible = _visible.toString()

		_.forEach object.fields, (field, key)->
			if field.options && _.isString(field.options)
				try
					_options = []
					#支持\n或者英文逗号分割,
					_.forEach field.options.split("\n"), (option)->
						if option.indexOf(",")
							options = option.split(",")
							_.forEach options, (_option)->
								_options.push(getOption(_option))
						else
							_options.push(getOption(option))
					field.options = _options
				catch error
					console.error "Creator.convertFieldsOptions", field.options, error

			else if field.options && !_.isFunction(field.options) && !_.isArray(field.options) && _.isObject(field.options)
				_options = []
				_.each field.options, (v, k)->
					_options.push {label: v, value: k}
				field.options = _options

			if Meteor.isServer
				options = field.options
				if options && _.isFunction(options)
					field._options = field.options.toString()
			else
				options = field._options
				if options && _.isString(options)
					try
						field.options = Creator.eval("(#{options})")
					catch error
						console.error "convert error #{object.name} -> #{field.name}", error

			if Meteor.isServer
				regEx = field.regEx
				if regEx
					field._regEx = field.regEx.toString()
			else
				regEx = field._regEx
				if regEx
					try
						field.regEx = Creator.eval("(#{regEx})")
					catch error
						console.error "convert error #{object.name} -> #{field.name}", error

			if Meteor.isServer
				if field.autoform
					_type = field.autoform.type
					if _type && _.isFunction(_type) && _type != Object && _type != String && _type != Number && _type != Boolean && !_.isArray(_type)
						field.autoform._type = _type.toString()
			else
				if field.autoform
					_type = field.autoform._type
					if _type && _.isString(_type)
						try
							field.autoform.type = Creator.eval("(#{_type})")
						catch error
							console.error "convert field -> type error", field, error

			if Meteor.isServer

				optionsFunction = field.optionsFunction
				reference_to = field.reference_to
				createFunction = field.createFunction
				beforeOpenFunction = field.beforeOpenFunction
				filtersFunction = field.filtersFunction

				if optionsFunction && _.isFunction(optionsFunction)
					field._optionsFunction = optionsFunction.toString()

				if reference_to && _.isFunction(reference_to)
					field._reference_to = reference_to.toString()

				if createFunction && _.isFunction(createFunction)
					field._createFunction = createFunction.toString()
				if beforeOpenFunction && _.isFunction(beforeOpenFunction)
					field._beforeOpenFunction = beforeOpenFunction.toString()

				if filtersFunction && _.isFunction(filtersFunction)
					field._filtersFunction = filtersFunction.toString()
			else

				optionsFunction = field._optionsFunction
				reference_to = field._reference_to
				createFunction = field._createFunction
				beforeOpenFunction = field._beforeOpenFunction
				filtersFunction = field._filtersFunction

				if optionsFunction && _.isString(optionsFunction)
					field.optionsFunction = Creator.eval("(#{optionsFunction})")

				if reference_to && _.isString(reference_to)
					field.reference_to = Creator.eval("(#{reference_to})")

				if createFunction && _.isString(createFunction)
					field.createFunction = Creator.eval("(#{createFunction})")

				if beforeOpenFunction && _.isString(beforeOpenFunction)
					field.beforeOpenFunction = Creator.eval("(#{beforeOpenFunction})")

				if filtersFunction && _.isString(filtersFunction)
					field.filtersFunction = Creator.eval("(#{filtersFunction})")

			if Meteor.isServer
				defaultValue = field.defaultValue
				if defaultValue && _.isFunction(defaultValue)
					field._defaultValue = field.defaultValue.toString()
			else
				defaultValue = field._defaultValue

				if !defaultValue && _.isString(field.defaultValue) && field.defaultValue.startsWith("function")
					defaultValue = field.defaultValue

				if defaultValue && _.isString(defaultValue)
					try
						field.defaultValue = Creator.eval("(#{defaultValue})")
					catch error
						console.error "convert error #{object.name} -> #{field.name}", error

		_.forEach object.list_views, (list_view, key) ->
			###
			视图过虑器需要支持function，后台转成字符串，前台eval成函数
			让过虑器支持两种function方式：
			1. 整个filters为function:
			如：
			filters: ()->
				return [[["object_name","=","project_issues"],'or',["object_name","=","tasks"]]]
			2. filters内的filter.value为function
			如：
			filters: [["object_name", "=", ()->
				return "project_issues"
			]]
			或
			filters: [{
				"field": "object_name"
				"operation": "="
				"value": "="()->
					return "project_issues"
			}]
			###
			if _.isFunction(list_view.filters)
				if Meteor.isServer
					list_view._filters = list_view.filters.toString()
			else if _.isString(list_view._filters)
				if Meteor.isClient
					list_view.filters = Creator.eval("(#{list_view._filters})")
			else
				_.forEach list_view.filters, (filter, _index)->
					if _.isArray(filter)
						if Meteor.isServer
							if filter.length == 3 and _.isFunction(filter[2])
								filter[2] = filter[2].toString()
								filter[3] = "FUNCTION"
						else
							if filter.length == 4 and _.isString(filter[2]) and filter[3] == "FUNCTION"
								filter[2] = Creator.eval("(#{filter[2]})")
								filter.pop()
					else if _.isObject(filter)
						if Meteor.isServer
							if _.isFunction(filter?.value)
								filter._value = filter.value.toString()
						else
							if _.isString(filter?._value)
								filter.value = Creator.eval("(#{filter._value})")


