(window.contosoUniversity = window.contosoUniversity || {}).shared = (function (document, $) {

    var _ajaxifyForms = function () {
        $('form[method=post]:not(.js-no-ajax)')
            .on('submit', function () {
                var $form = $(this);
                var submitButton = $form.find('[type="submit"]:first');
                var data = $form.serialize();
                var url = $form.prop('action');

                submitButton.prop('disabled', true);

                $.ajax({
                    method: 'POST',
                    url: url,
                    data: data,
                })
                .done(function () {
                    alert("success");
                })
                .fail(function () {
                    alert("error");
                })
                .always(function () {
                    submitButton.prop('disabled', false);
                    alert("complete");
                });


                return false;
            });
    }

    var initialise = function () {
        _ajaxifyForms();
    };

    return {
        initialise: initialise
    };

})(document, window.jQuery);