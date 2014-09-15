#= require jquery
#= require jquery_ujs
#= require admin-lte/active_admin_has_many
#= require admin-lte/jquery.velocity.min
#= require admin-lte/bootstrap
#= require admin-lte/bootstrap.wysiwyg
#= require admin-lte/picker
#= require admin-lte/picker.date
#= require admin-lte/picker.time
#= require admin-lte/bootbox.min
#= require admin-lte/app
#= require_self

$.rails.allowAction = (link) ->
  return true unless link.attr('data-confirm')
  $.rails.showConfirmDialog(link) # look bellow for implementations
  false # always stops the action since code runs asynchronously

$.rails.confirmed = (link) ->
  link.removeAttr('data-confirm')
  link.trigger('click.rails')

$.rails.showConfirmDialog = (link) ->
  message = link.attr 'data-confirm'
  bootbox.confirm
    message: message
    className: 'action-confirm'
    backdrop: true
    animate: false
    callback: (result)->
      $.rails.confirmed(link) if result

class LTEDateTime
  constructor: (el)->
    @el = $(el)

    @defineInstanceEl()
    @buildPickerDate()
    @buildPickerTime()
    @setupListener()

  defineInstanceEl: ->
    @timePickerContainer = @el.find('.lte-date-time-container > .time')
    @datePickerContainer = @el.find('.lte-date-time-container > .date')
    @inputEl             = @el.find('.lte-date-time-input')

  setupListener: ->
    @inputEl
      .on('focus', @datePicker.open)
      .on('click', (e)-> e.stopPropagation())

  buildPickerTime: ->
    @timePicker = @el.find('.time-placeholder').pickatime({
      container: @timePickerContainer
      onSet: (item)=>
        @applyDateTime() if @_isSelect(item)
    }).pickatime('picker')

  buildPickerDate: ->
    @datePicker = @el.find('.date-placeholder').pickadate({
      container: @datePickerContainer
      onSet: (item)=>
        @applyDateAndShowTime() if @_isSelect(item)
    }).pickadate('picker')


  applyDateAndShowTime: ->
    @inputEl.val @datePicker.get()
    @timePicker.open()

  applyDateTime: ->
    @inputEl.val(@inputEl.val()+ ' ' + @timePicker.get())
    @inputEl.blur()

  _isSelect: (item)->
    ('select' in (keys for keys, values of item))

class LTEDateRangeFilter
  constructor: (el)->
    @el = $(el)

    @defineInstanceEl()
    @buildPickerPlaceHolder()
    @buildPickerDateStart()
    @buildPickerDateEnd()
    @setupListener()

  setupListener: ->
    @startInputEL
      .on('focus', @pickerStart.open)
      .on('click', (e)-> e.stopPropagation())

    @endInputEL
      .on('focus', @pickerEnd.open)
      .on('click', (e)-> e.stopPropagation())

  defineInstanceEl: ->
    @startInputEL = @el.find('.datepicker').eq(0)
    @endInputEL = @el.find('.datepicker').eq(1)

  buildPickerDateStart: ->
    @pickerStart = @el.find('.start-date-placeholder').pickadate({
      onSet: (item)=>
        @applyStart() if @_isSelect(item)

    }).pickadate('picker')

  buildPickerDateEnd: ->
    @pickerEnd = @el.find('.end-date-placeholder').pickadate({
      onSet: (item)=>
        @applyEnd() if @_isSelect(item)
    }).pickadate('picker')


  applyStart: =>
    @startInputEL.val @pickerStart.get('select', 'yyyy-mm-dd')
    @startInputEL.blur()

  applyEnd: =>
    @endInputEL.val @pickerEnd.get('select', 'yyyy-mm-dd')
    @endInputEL.blur()

  openPickerEnd: =>
    @pickerEnd.open()

  buildPickerPlaceHolder: ->
    startDatePlaceholderTpl = '<div class="date-input-placeholder"> <input type="text" class="start-date-placeholder hidden"/> </div>'
    endDatePlaceholderTpl   = '<div class="date-input-placeholder"> <input type="text" class="end-date-placeholder hidden"/> </div>'
    @startInputEL.after( $ startDatePlaceholderTpl)
    @endInputEL.after( $ endDatePlaceholderTpl )

  _isSelect: (item)->
    ('select' in (keys for keys, values of item))

$(document).ready ->
  $('.sidebar-menu .has_nested').tree()
  $('.filter-toggle .btn').click ->
    filterIndex = $('.index-filter-outer')
    isActive    = filterIndex.hasClass('active')
    height      = filterIndex.height()

    filterIndex.removeClass('expand') if filterIndex.hasClass('expand')

    if !isActive
      filterIndex.addClass('active')
      filterIndex = $('.index-filter-outer')
      height      = filterIndex.height()
      triggerAfterOpen = =>
        filterIndex.trigger 'filter:opened'
      filterIndex.trigger 'filter:beforeOpen'
      filterIndex.css(height: '0px').velocity(height: height, triggerAfterOpen)
    else
      cleanActive = ->
        filterIndex.trigger 'filter:closed'
        filterIndex.removeClass('active')
        filterIndex.removeAttr('style')

      filterIndex.trigger 'filter:beforeClose'
      filterIndex .css(height: height).velocity( height: '0px', cleanActive )

  for lteDateTime in $('.lte-date-time')
    new LTEDateTime(lteDateTime)

  for lteDateRangeFilter in $('.filter_date_range')
    new LTEDateRangeFilter(lteDateRangeFilter)

  $('.index-filter-outer').on('filter:opened', (e)->
    el = $(e.currentTarget)
    el.data('original-overflow', el.css('overflow'))
    el.css('overflow', 'visible')
  )

  $('.index-filter-outer').on('filter:beforeClose', (e)->
    el = $(e.currentTarget)
    el.css('overflow', el.data('original-overflow'))
  )

  # ------------------------- batch
  toggleResourceSelection = (e)->
    el = $ e.currentTarget
    children = $('.resource_selection_cell .collection_selection')
    if el.is(":checked") is true
      children.prop("checked", true)
    else
      children.prop("checked", false)

    children.trigger('change')

  resourceSelectionChangeHandler = (e)->
    batchBtnTrigger = $ '.batch_action_dropdown button[data-toggle]'
    el = $ e.currentTarget
    window.resourceSelectionsForBatch = [] unless window.resourceSelectionsForBatch?
    id = el.data('resource-id')
    if el.is(":checked") is true
      window.resourceSelectionsForBatch.push(  id ) if window.resourceSelectionsForBatch.indexOf(id) == -1
    else
      index = window.resourceSelectionsForBatch.indexOf(id)
      window.resourceSelectionsForBatch.splice(index, 1) if index > -1

    if window.resourceSelectionsForBatch.length == 0
      batchBtnTrigger.prop('disabled', true)
    else
      batchBtnTrigger.prop('disabled', false)

  resourceSelections = $('.resource_selection_cell .collection_selection')
  resourceSelections.change resourceSelectionChangeHandler
  $('.resource_selection_toggle_cell #collection_selection_toggle_all').change toggleResourceSelection

  submitBatch     = (e)->
    batchBtnTrigger = $ '.batch_action_dropdown button[data-toggle]'
    el        = $ e.currentTarget
    action    = el.data('action')
    urlTarget = batchBtnTrigger.data('target-url')
    csrfKey   = $(document).find('meta[name="csrf-param"]').attr('content')
    csrfToken = $(document).find('meta[name="csrf-token"]').attr('content')

    #build virtual form
    formTpl = """
      <form accept-charset="UTF-8" action="#{urlTarget}" method="post" style="display: none">
      <input name="utf8" value="✓"/>
      <input name="#{csrfKey}" value="#{csrfToken}"/>
      <input name="batch_action_inputs" value="{}"/>
      <input name="batch_action" value="#{action}"/>
    """

    formTpl += """
      <input type="text" value="#{resourceId}" name="collection_selection[]"/>
    """ for resourceId in window.resourceSelectionsForBatch
    formTpl += "</form>"

    compiledForm = $( formTpl )
    compiledForm.submit()


  batchActionBtns = $ '.batch_action_dropdown ul.dropdown-menu > li > a'
  batchActionBtns.on('confirm:complete', submitBatch)
  batchActionBtns.click (e)->
    e.stopPropagation()
    e.preventDefault()

    if !window.resourceSelectionsForBatch? or window.resourceSelectionsForBatch.length < 1
      bootbox.alert
        message: 'no resource selected'
        className: 'action-confirm'
        backdrop: true
        animate: false
      return false

    if message = $(@).data 'confirm'
      that = @
      bootbox.confirm
        className: 'action-confirm'
        message: message
        backdrop: true
        animate: false
        callback: (result)->
          $(that).trigger 'confirm:complete'
    else
      $(@).trigger 'confirm:complete'
  # ------------------------- batch
