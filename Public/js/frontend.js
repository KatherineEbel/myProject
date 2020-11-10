const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-toggle="popover"]'))
const popoverList = popoverTriggerList.map(popover => new bootstrap.Popover(popover))
