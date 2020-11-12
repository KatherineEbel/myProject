$('.modal-trigger').click(function() {
    let $target = $(this)
    let itemTitle = $target.data("title")
    let id = $target.data("id")
    let $form = $('form')
    $form.attr('action', `/admin/blog/posts/${id}/delete/`)
    $('.modal-title').text(`Deleting post ${itemTitle}`)
    $form.submit(() => {
        $('#exampleModal').modal('hide')
    })
})

$(function () {
    $('#categoryId').select2()
})


