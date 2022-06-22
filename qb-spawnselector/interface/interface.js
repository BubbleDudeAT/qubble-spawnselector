window.addEventListener('message', function(event) {
    let data = event.data;

    switch (data.event) {
        case 'show':
            $("body").show();
            break;

        case 'hide':
            $("body").hide();
            break;

        case 'update':
            $(".name").html(data.label);
            break;
    }
});

$(".button").click(function() {
    let el = $(this), type = el.attr("type");
    if (type) {
        $.post(`https://qb-spawnselector/${type}`);
    }
});

$(".button1").click(function() {
    let el = $(this), type = el.attr("type");
    if (type) {
        $.post(`https://qb-spawnselector/${type}`);
    }
});

$(".spawn").click(function() {
    $.post(`https://qb-spawnselector/spawn`);
});

$(".lastloc").click(function() {
    $.post(`https://qb-spawnselector/lastloc`);
});