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

function chooseImage() {
    document.getElementById('imageDelete').value = false
    document.getElementById('image').click()
}

function removeImage() {
    document.getElementById('image').value = null
    document.getElementById('imageDelete').value = true
    const el = document.querySelector('.preview')
    if (el !== null) {
        el.parentNode.removeChild(el)
    }
}

document.getElementById('image').onchange = event => {
    const file = event.target.files[0]
    const blobURL = URL.createObjectURL(file)
    let el = document.querySelector('.preview')
    if (el === null) {
//      <img class="img-fluid img-thumbnail preview" src="#(form.image.value)" alt="preview image"
//           style="height: 80px; width: 160px;"
//      />
        let newEl = document.createElement('img')
        newEl.className = "img-fluid img-thumbnail preview"
        newEl.alt = "preview image"
        const sibling = document.getElementById('choose-button')
        sibling.parentNode.insertBefore(newEl, sibling)
        el = newEl
    }
    el.src = blobURL
}
