(window.contosoUniversity = window.contosoUniversity || {}).shared = (function (document, $) {

    var _highlightErrors = function (jqXHR) {
        var jsonResponse = JSON.parse(jqXHR.responseText);
        _highlightFields(jsonResponse.errors);
        window.scrollTo(0, 0);
        console.log('jsonResponse', jsonResponse);
    }

    var _highlightFields = function (errors) {

        function capitalizeFirstLetter(string) {
            return string.charAt(0).toUpperCase() + string.slice(1);
        }

        $('.form-group').removeClass('has-error');

        $.each(errors, function (errorElementId) {
            var $element = $('#' + capitalizeFirstLetter(errorElementId));
            $element
                .closest('.form-group')
                .addClass('has-error');
        });
    }

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
                    .fail(_highlightErrors)
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