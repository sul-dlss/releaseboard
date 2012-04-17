# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

getNotificationData = (sender) ->
  div = $(sender).parents('.notification-container')
  return([div, div.data()])

bindHandlers = (container) ->
  relative_root_url = $('body').data('root')
  
  $('form.edit_notification', container).submit ->
    sender = $(this)
    [container, data] = getNotificationData(sender)
    $.ajax "#{relative_root_url}/notifications/#{data.notificationId}",
      type: 'PUT'
      data: sender.serialize()
      complete: (data, status, xhr) -> 
        newContainer = $(data.responseText)
        container.replaceWith(newContainer)
        bindHandlers(newContainer)
    return false
    
  $('form.new_notification', container).submit ->
    sender = $(this)
    [container, data] = getNotificationData(sender)
    projectId = $('#new_notification_form').data('projectId')
    $('#new_notification_form form input[name="notification[project_id]"]').val(projectId)
    $.ajax "#{relative_root_url}/notifications",
      type: 'POST'
      data: sender.serialize()
      complete: (data, status, xhr) -> 
        newContainer = $(data.responseText)
        if data.getResponseHeader('X-Valid-Model') == 'false'
          container.replaceWith(newContainer)
        else
          $('#notifications_table').append(newContainer)
          $('.new_notification .cancel.button').trigger('click');
        bindHandlers(newContainer)
    return false
  
  $('.edit_notification .cancel.button', container).click ->
    $('input[name="cancel"]',$(this).closest('form')).val(true)
    return true

  $('.new_notification .cancel.button', container).click ->
    projectId = $('#new_notification_form').data('projectId')
    $('#new_notification_form').hide();
    $('#new_notification_button').show();
    $.ajax "#{relative_root_url}/projects/#{projectId}/notifications/new",
      type: 'GET'
      complete: (data, status, xhr) -> 
        $('#new_notification_form').html(data.responseText)
        bindHandlers($('#new_notification_form'))
    return false
    
  $('a.edit.notification-link', container).click ->
    sender = $(this)
    [container, data] = getNotificationData(sender)
    $.ajax "#{relative_root_url}/notifications/#{data.notificationId}/edit",
      dataType: 'html',
      success: (data, status, xhr) -> 
        newContainer = $(data)
        container.replaceWith(newContainer)
        bindHandlers(newContainer)
    return false
  
  $('a.delete.notification-link', container).click ->
    sender = $(this)
    [container, data] = getNotificationData(sender)
    $.ajax "#{relative_root_url}/notifications/#{data.notificationId}.json",
      type: 'DELETE'
      dataType: 'json'
      success: (data, status, xhr) -> container.remove()
      
  $('a.create.notification-link', container).click ->
    $('#new_notification_button').hide();
    $('#new_notification_form').show();
    $('#new_notification_form form')[0].reset();
    return false
    
$ ->
  $('.tabbish.sub-nav dd a').click ->
    $('.tabs-content li.active').removeClass('active')
    $('.tabbish.sub-nav dd.active').removeClass('active')
    $(this.hash).addClass('active')
    $(this).parent().addClass('active')
    true
    
  for container of $('.notification-container')
    bindHandlers(container)
  
  d = $('#project_description')
  d.height($('#text_fields').height()-27)
  d.width(d.parent().width())