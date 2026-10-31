// new WOW().init();

$(document).ready(function(){
    
    // Iframe Lazy Load
    setTimeout(function() {
    	$('.iframe.lezy').each(function (i, e) {
    		var html = $(e).html();
    		html = html.replace('eframe', 'iframe');
    		$(e).html(html).removeClass('lezy');
        })
    }, 2000)
    
    // END Iframe Lazy Load
    
     let headSwiper = new Swiper('.mobile__slider.swiper',{
        loop: true,
        loopedSlides: 5,
        loopAdditionalSlides: 5,
        //autoHeight: true,
        freeMode: true,
        spaceBetween: 30,
        slidesPerView: "auto",
        grabCursor: true,
        //mousewheelControl: true,
        keyboardControl: true,
        loopedSlides: 100,
    })
    
    // $(".mobile__slider .owl-carousel").owlCarousel({
    //     nav: false,
    //     navText: ["", ""],
    //     dots: false,
    //     smartSpeed: 1000,
    //     responsive:{
    //         0:{
    //             items:1,
    //             margin: 10
    //         },
    //         541:{
    //             items:2,
    //             margin: 10,
    //         },
    //         960:{
    //             items:2,
    //             margin: 10,
    //         },
    //         1025:{
    //             items:2,
    //             margin: 15,
    //         },
          
    //     }
    // });
    
    // if(document.documentElement.clientWidth > 768) {
    //     $("[data-fancybox]").click(function() {
    //         return false;
    //     });
    // }
    // $(".portfolio__cols_bg [data-fancybox]").click(function() {
    //     return false;
    // });
    
    
/*Делаем плавную прокрутку при клике на якорную ссылку:*/
$("body").on('click', '[href*="#"]', function (e) {
    $('html,body').stop().animate({ scrollTop: $(this.hash).offset().top - 50 }, 1000);
    e.preventDefault();
});
/*Делаем плавную прокрутку при клике на якорную ссылку:*/
$(function () {
    var curlvl;
    /*startlvl = 2; - для Blogger*/
    var startlvl = 0;
    var prevlvl = startlvl;
    /*toc - наш контейнер*/
    var lst = $("#toc");
    /*решил вынести заголовок Содержания сюда - и управлять проще и индексироваться не будет.*/
    var tmp2 = $("<h3>Оглавление</h3>");
    lst.append(tmp2);
    /*текущий полный URL - актуально если у вас не работают якорные ссылки из-за тега base, задающий относительность урлов.*/
    var href1 = window.location.href;
    /*вырезаем якоря в URL - так решил проблему зацикливания на якорях. пример зацикливания: site.ru/ ... /page#title1#title2 ...*/
    var href2 = href1.replace(window.location.hash, "");
    if (typeof lst !== "undefined") {
        /*.text_read h1, .text_read h2, .text_read h3, .text_read h4 - указываете свой путь к заголовкам.*/
        $(".article__content h1, .article__content h2, .article__content h3, .article__content h4").each(function (i) {
            var current = $(this);
            current.attr("id", "title" + i);
            for (curlvl = parseInt(current.prop("tagName").substring(1)); curlvl > prevlvl; prevlvl++) {
                var tmp = $("<ul></ul>");
                if (prevlvl == startlvl)
                    lst.append(tmp);
                else {
                    var last_li = $("#toc li").last();
                    last_li.append(tmp);
                }
                if (curlvl > prevlvl + 1)
                    tmp.append("<li style=\"list-style-type: none\"></li>");
                lst = tmp;
            }
            while (curlvl < prevlvl) {
                lst = lst.parent().parent();
                prevlvl--;
            }
            /*убираем двоеточие в конце заголовка для ссылки в оглавлении:*/
            curder = current.html();
            if (curder.charAt(curder.length - 1) == ':') {
                curder = curder.substr(0, curder.length - 1);
            }

            /*href2 - исправляет проблему с тегом base и зацикливанием якорей; itemprop='url' - элемент микроразметки; curder - анкор без двоеточия в конце подстроки:*/
            lst.append("<li><a id='link" + i + "' itemprop='url' href='" + href2 + "#title" + i + "' title='" + current.html() + "'>" + curder + "</a></li>");
        });
    }
});

    
  
    
    
    // $(".owl-carousel").owlCarousel({
    //     items: 1,
    //     nav:true,
    //     navText : ["",""],
    //     dots: false
    // });

    $(".stages__slider .owl-carousel").owlCarousel({
        items: 1,
        nav:true,
        navText : ["",""],
        dots: true,
        animateOut: 'fadeOut',
        smartSpeed:450,
        mouseDrag: false,
        touchDrag: false,
        pullDrag: false,
        animateIn: 'slideInDown',
    }).find('.owl-item')
        .each(function(i){
        var attr = $(this).children().attr('data-year');
        var element = $('<span>'+attr+'</span>');
        $('.stages__slider .owl-carousel .owl-dot').eq(i).append(element);
    });

    $(".reviews__slider .owl-carousel").owlCarousel({
        items: 1,
        nav:true,
        navText : ["",""],
        dots: false,
        animateOut: 'fadeOut',
        smartSpeed:450,
        mouseDrag: false,
        touchDrag: false,
        pullDrag: false,
        animateIn: "slideInDown",
    });

    $(".team__slider .owl-carousel").owlCarousel({
        nav:true,
        navText : ["",""],
        dots: false,
        smartSpeed:1000,
        responsive:{
            0:{
                items:1,
                margin: 10
            },
            520:{
                items:2,
                margin: 15,
            },
            768:{
                items:3,
                margin: 15,
            },
            1360:{
                items:5,
                margin: 30,
            },
        }
    });

    $('.reviews__slider .owl-carousel').on('changed.owl.carousel', function(e) {
        var slideKey= e.item.index + 1;
        if (!e.namespace || e.property.name != 'position') return
        
        let text = slideKey < 10 ? `0${slideKey}` : slideKey;
        $('#info').text(text);
        
        text = e.item.count < 10 ? `0${e.item.count}` : e.item.count;
        $('#info-num').text('/'+ text);
      })


    $(".info-contacts__mouse").on("click","a", function (event) {
        event.preventDefault();
        var id  = $(this).attr('href'),
            top = $(id).offset().top;
        $('body,html').animate({scrollTop: top}, 1500);
    });
    $(".tabs-wrapper .tab").click(function() {
        $(".tabs-wrapper .tab").removeClass("active").eq($(this).index()).addClass("active");
        $(".tab_item").hide().eq($(this).index()).fadeIn()
    }).eq(0).addClass("active");

    $(".questions-caption").on("click", function (){
        $(this).find("img").toggleClass("opened");
        $(this).next().slideToggle();
    });

    $("#menu__toggle").on("click", function (){
        $(".header-logo").toggleClass("humburger");
        $(".menu__box").toggleClass("next");
        $('body').toggleClass("fixedPosition");
        $(".menu__main").show();
        $(".contacts-menu").hide();
        $(".header__dropdown").hide();
        $('.header').removeClass('dropdown-opened');
    });
    $(".blog-nav").on("click", function (){
        $(".nav-child").toggleClass("open");
        $(".blog-nav span").toggleClass("open");
    });

    if(document.documentElement.clientWidth > 768) {
        $(".menu-haschild").hover(function() {
            $('.dropdown-list').stop(true, true).delay(200).fadeIn(300);
        
            }, function() {
            $('.dropdown-list').stop(true, true).delay(200).fadeOut(300);
        });
        $(".menu-lst").hover(function() {
            $('.dropdown-lst').stop(true, true).delay(200).fadeIn(300);
        
            }, function() {
            $('.dropdown-lst').stop(true, true).delay(200).fadeOut(300);
        });
        $(".menu-secn").hover(function() {
            $('.dropdown-secn').stop(true, true).delay(200).fadeIn(300);
        
            }, function() {
            $('.dropdown-secn').stop(true, true).delay(200).fadeOut(300);
        });
        $(".menu-next").hover(function() {
            $('.dropdown-next').stop(true, true).delay(200).fadeIn(300);
        
            }, function() {
            $('.dropdown-next').stop(true, true).delay(200).fadeOut(300);
        });
    }
    if(document.documentElement.clientWidth < 768) {
        $(".menu-haschild").click(function() {
            $('.dropdown-list').slideDown(300);
        });
        $(".menu-lst").click(function() {
            $('.dropdown-lst').slideToggle(300);
        });
        $(".menu-secn").click(function() {
            $('.dropdown-secn').slideToggle(300);
        });
        $(".menu-next").click(function() {
            $('.dropdown-next').slideToggle(300);
        });
    }
    $(".seo-yakori").on("click","a", function (event) {
        event.preventDefault();
        var id  = $(this).attr('href'),
            top = $(id).offset().top;
        $('body,html').animate({scrollTop: top}, 1500);
    });
    $(".creation__wrap .tab").click(function() {
        $(".creation__wrap .tab").removeClass("active").eq($(this).index()).addClass("active");
        $(".tab_item").hide().eq($(this).index()).fadeIn()
    }).eq(0).addClass("active");

    $(".questions__line_click").on("click", function (){
        $(this).find('.questions__line').next().slideToggle();
        $(this).find('.questions__line').toggleClass('opened');
        $(this).find('.questions__arrow').toggleClass('active');
    });

    // popup Обсудить проект
    $('#discuss-btn').click( function() {
        $('.overlay__discuss').fadeIn();
    });
    $('.close__discuss').click( function() {
        $('.overlay__discuss').fadeOut();
    });
    $(document).mouseup( function (e) { 
        var popup = $('.popup__discuss');
        if (e.target != popup[0] && popup.has(e.target).length === 0){
            $('.overlay__discuss').fadeOut();
        }
    });
    
    // popup SEO Аудит
    $('#audit-btn').click( function() {
        $('.overlay__audit').fadeIn();
    });
    $('.close__discuss').click( function() {
        $('.overlay__audit').fadeOut();
    });
    $(document).mouseup( function (e) { 
        var popup = $('.popup__audit');
        if (e.target != popup[0] && popup.has(e.target).length === 0){
            $('.overlay__audit').fadeOut();
        }
    });
    
    // popup video reviews
    $('.reviews__link').click( function() {
        const dataIndex = $(this).data('index');
        $(`.overlay_video[data-index*="${dataIndex}"]`).fadeIn();
    });
    $('.close-popup_video').click( function() {
        $('.overlay_video').fadeOut();
    });
    $(document).mouseup( function (e) { 
        var popup = $('.popup_video');
        if (e.target != popup[0] && popup.has(e.target).length === 0){
            $('.overlay_video').fadeOut();
        }
    });

    
    // dropdowm services menu

    if(document.documentElement.clientWidth > 840) {
        $(".list-navigation__item.list_item-services, .list-navigation__item.list_item-poslugy").hover(function() {
            var isHovered = $(this).is(":hover");
            if (isHovered) {
                $('.header').addClass('dropdown-opened');
                $('.main .main-about.main-about__black').addClass('opend');
                $('.header__dropdown').stop().slideDown(300);
            }
            else{
                $('.main .main-about.main-about__black').removeClass('opend');
            }
        });
    }
    if(document.documentElement.clientWidth > 840) {
        $(".header__dropdown").hover(function() {
            var menuIsHovered = $('.header.dropdown-opened .header__dropdown').is(":hover");
            if (menuIsHovered) {
                $('.header').addClass('dropdown-opened');
                $('.header__dropdown').stop().slideDown(300);
            }
            else{
                $('.header').removeClass('dropdown-opened');
                $('.header__dropdown').stop().slideUp(300);
            }
        });
    }

    if(document.documentElement.clientWidth < 840) {
        $('.list-navigation__item.list_item-services .mob_menu_arrow, .list-navigation__item.list_item-poslugy .mob_menu_arrow').on("click", function (e){
            e.preventDefault();
            $(".menu__main").hide();
            $(".header__dropdown").show();
            $('.header').addClass('dropdown-opened');
        });
    }
    if(document.documentElement.clientWidth < 840) {
        $(".header__phone_desktop").on("click", function (){
            $('#menu__toggle').prop('checked', true);
            $(".menu__main").hide();
            $(".contacts-menu").show();
            $('.contacts-menu').addClass('new');
            $("#menu__toggle").click(function () {
                if($('.contacts-menu').hasClass('new')){
                    $(".header-logo").removeClass("humburger");
                    $(".menu__box").removeClass("next");
                    $('body').removeClass("fixedPosition");
                    $(".menu__main").hide();
                    $(".contacts-menu").hide();
                    $(".header__dropdown").hide();
                    $('.header').removeClass('dropdown-opened');
                    $('.contacts-menu').removeClass('new');
                }
            });
        });
    }
    
    $('#projects_list').delegate(".works__btn", "click", function(){
        const left = $('#projects_list-left .works__item.hidden');
        const right = $('#projects_list-right .works__item.hidden');
        
        if ( left.length !== 0 ) {
            
            $(left).each(function(index) {
                if ( index < 3 ) $(this).removeClass('hidden');
            })
            
        }
        
        if ( right.length !== 0 ) {
            
            $(right).each(function(index) {
                if ( index < 3 ) $(this).removeClass('hidden');
            })
            
        }
        
        if ( ( left.length - 3 ) <= 0 && ( right.length - 3 ) <= 0 ) {
            $(this).hide();
        }
    })

    // $(".prices__line").on("click", function (){
    //     $(this).find("img").toggleClass("opened");
    //     $(this).next().slideToggle();
    // });
    
    $('.services-page__tab').click(function() {
      $('.services-page__tab').removeClass('services-page__tab_active');
      $(this).addClass('services-page__tab_active');
    });
    

     // yakor link comments

     $(".comments__titles").on("click","a", function (event) {
        event.preventDefault();
        var id  = $(this).attr('href'),
            top = $(id).offset().top;
        $('body,html').animate({scrollTop: top}, 1500);
    });
    
    
    // seo hidden
    var totalHeight = 0;

    $(".seo-hidden .creation__text").children().each(function(){
    console.log(totalHeight);
        totalHeight = totalHeight + $(this).outerHeight(true);
    });
    

    let seoHiddenHeight = $($('.seo-hidden .creation__text').children()[0]).outerHeight(true) + $($('.seo-hidden .creation__text').children()[1]).outerHeight(true);
    $('.seo-hidden .creation__text').height(seoHiddenHeight);

    $('.seo-hidden .read-more').click(function(e) {
        e.preventDefault();
        const lang = $('html').attr('lang');
        const textHidden = lang == 'uk' ? 'Сховати' : 'Скрыть';
        const textShow = lang == 'uk' ? 'Читати далі' : 'Читать далее';
        
        let isOpened =  $(this).data('click');
        $('.seo-hidden .creation__text').toggleClass('opened');
        isOpened ? $(this).text(textHidden) : $(this).text(textShow);
        $(this).data('click', !isOpened);
    })
    
    
    // Portfolio sort
    // $('#projects_list').delegate('.projects__filter span', 'click', function(){
    //     const data = $(this).data('val');
    //     $(this).toggleClass('active_filter');
    //     $.post(document.location.href, {action: 'getPortfolio', contentType: 'application/x-www-form-urlencoded; charset=UTF-8', data}, function(data) {
    //         // полученный ответ выводим в блок, имеющий идентификатор getPortfolio     
    //         // вывод блок будем сопровождать анимацией
    //         $('#projects_list').html(data);
    //     });
    // })
    // $('.works__head p').click(function(){
    //     $.post(document.location.href, {action: 'getPortfolio', contentType: 'application/x-www-form-urlencoded; charset=UTF-8', data: 'val_0'}, function(data) {
    //         // полученный ответ выводим в блок, имеющий идентификатор getPortfolio     
    //         // вывод блок будем сопровождать анимацией
    //         $('#projects_list').html(data);
    //     });
    // })
});

function copytext(el) {
    var $tmp = $("<input>");
    $("body").append($tmp);
    $tmp.val($(el).data('link')).select();
    document.execCommand("copy");
    $tmp.remove();
    
    $('.copy_alert').fadeIn();
    $('.copy_alert').delay(3000).fadeOut(1000);
}

if(document.documentElement.clientWidth > 768) {
    var s = skrollr.init();
}

new WOW().init();