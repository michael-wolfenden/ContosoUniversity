(window.contosoUniversity = window.contosoUniversity || {}).shared = (function (document, reqwest) {

    var _ajaxifyForms = function () {
        var formsToAjaxify = document.querySelectorAll('form[method=post]:not(.js-no-ajax)');
        [].forEach.call(formsToAjaxify, _ajaxifyForm);
    }

    var _ajaxifyForm = function (form) {
        var submitButton = form.querySelectorAll('[type="submit"]')[0];

        function disableSubmitButton() {
            submitButton.setAttribute('disabled', 'disabled');
        }

        function enableSubmitButton() {
            submitButton.removeAttribute('disabled');
        }

        function onSubmit(event) {
            event.preventDefault();

            disableSubmitButton();

            reqwest({
                url: form.getAttribute('action'),
                type: 'json',
                method: 'post',
                data: reqwest.serialize(form),
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
            .then(function (resp) { })
            .fail(function (err, msg) { })
            .always(enableSubmitButton)
        }

        form.addEventListener('submit', onSubmit);
    }

    var initialise = function () {
        _ajaxifyForms();
    };

    return {
        initialise: initialise
    };

})(document, window.reqwest);