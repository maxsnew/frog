#lang at-exp racket/base

(require (for-syntax racket/base
                     racket/syntax)
         racket/contract/base
         racket/string
         racket/function
         scribble/srcdoc
         (for-doc racket/base
                  scribble/manual)
         "private/define-doc.rkt")

;; Functions provided by this module are made available by
;; `render-template` to templates like `page-template.html` and
;; `post-template.html`. You could describe functions here as
;; "widgets": handy bits of functionality to use in templates.
;;
;; Not only does this make the templates simpler, it clarifies the
;; parameterization (the stuff the user is supposed to supply) better
;; than "CHANGE ME!" comments in the templates. Clearly, the
;; user-supplied stuff is what's passed in arguments to the widgets.
;;
;; Widgets should return `string?` or `(listof string?)` -- the latter
;; via @-expressions like `@list{ .... }`. You can write them using
;; normal Racket code like `format`. However for longer bits of HTML
;; and/or JavaScript it can be clearer to use at-exps, as the examples
;; here use.
;;
;; Pull requests welcome! If you've customized your template files
;; with something you'd like to share, please fork, add to this file,
;; and submit a pull request.
;;
;; Note: This file may confuse editors -- do you want Scheme/Racket
;; mode, HTML mode, or JavaScript mode? Well, you probably want each
;; at different times. Just please do your best to follow the
;; indentation style already being used.

(define/doc (older/newer-links [older-uri (or/c #f string?)]
                               [older-title (or/c #f string?)]
                               [newer-uri (or/c #f string?)]
                               [newer-title (or/c #f string?)]
                               list?)
  @{Returns HTML for a Bootstrap @tt{pager} style older/newer navigation.}
  @list{
        <ul class="pager">
        @(when newer-uri
          @list{
                <li class="previous">
                  <a href="@newer-uri">&larr; <em>@|newer-title|</em></a>
                </li>
                })
        @(when older-uri
          @list{
                <li class="next">
                  <a href="@older-uri"><em>@|older-title|</em> &rarr;</a>
                </li>
                })
        </ul>
        })

(define/doc (disqus-comments [short-name string?] list?)
  @{@hyperlink["https://disqus.com/"]{Disqus} comments. Typically used in
    @secref["post-template"].}
  @list{
        <script type="text/javascript">
          var disqus_shortname = '@|short-name|';
          (function() {
              var dsq = document.createElement('script');
              dsq.type = 'text/javascript';
              dsq.async = true;
              dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
              (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
          })();
        </script>
        <div id="disqus_thread"></div>
        })

(define/doc (livefyre [site-id string?] list?)
  @{@url["http://livefyre.com"]}
  @list{
        <div id="livefyre-comments"></div>
        <script type="text/javascript" src="//zor.livefyre.com/wjs/v3.0/javascripts/livefyre.js"></script>
        <script type="text/javascript">
        (function () {
            var articleId = fyre.conv.load.makeArticleId(null);
            fyre.conv.load({}, [{
                el: 'livefyre-comments',
                network: "livefyre.com",
                siteId: "@|site-id|",
                articleId: articleId,
                signed: false,
                collectionMeta: {
                    articleId: articleId,
                    url: fyre.conv.load.makeCollectionUrl(),
                }
            }], function() {});
        }());
        </script>})

(define/doc (intense-debate [id-account string?] list?)
  @{@url["https://intensedebate.com/"]}
  @list{
        <script type="text/javascript">
        var idcomments_acct = '@|id-account|';
        var idcomments_post_id;
        var idcomments_post_url;
        </script>
        <span id="IDCommentsPostTitle" style="display:none"></span>
        <script type='text/javascript' src='//www.intensedebate.com/js/genericCommentWrapperV2.js'></script>})

(define/doc (google-universal-analytics [account string?] list?)
  @{For users of ``universal'' analytics (@filepath{analytics.js}).}
  @list{
         <script type="text/javascript">
           (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
           (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
           m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
           })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

           ga('create', '@|account|', 'auto');
           ga('send', 'pageview');
         </script>
         })

(define/doc (google-analytics [account string?]
                              [domain string?]
                              list?)
  @{For users of ``classic'' analytics (@filepath{ga.js}).}
  @list{
         <script type="text/javascript">
           var _gaq = _gaq || [];
           _gaq.push(['_setAccount', '@|account|']);
           _gaq.push(['_setDomainName', '@|domain|']);
           _gaq.push(['_trackPageview']);
           setTimeout(function(){_gaq.push(['_trackEvent', '30_seconds', 'read'])}, 30000); // http://drawingablank.me/blog/fix-your-bounce-rate.html
           (function() {
               var ga = document.createElement('script');
               ga.type = 'text/javascript'; ga.async = true;
               ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
               var s = document.getElementsByTagName('script')[0];
               s.parentNode.insertBefore(ga, s);
           })();
         </script>
         })

(define/doc (google-plus-share-button [full-uri string?] list?)
  @{Typically used in a @secref["post-template"].}
  @list{<script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script>
        <g:plusone size="medium" href="@full-uri"></g:plusone>})

(define/doc (twitter-follow-button [name string?]
                                   [label (or/c #f string?) #f]
                                   list?)
  @{Typically used in a @secref["page-template"].}
  (let ([label (or label (string-append "Follow " name))])
    @list{
          <a href="https://twitter.com/@|name|"
             class="twitter-follow-button"
             data-show-count="false"
             data-lang="en">
            "@|label|"
          </a>
          <script type="text/javascript">
            !function(d,s,id){
                var js,fjs=d.getElementsByTagName(s)[0];
                if(!d.getElementById(id)){
                    js=d.createElement(s);
                    js.id=id;
                    js.src="//platform.twitter.com/widgets.js";
                    fjs.parentNode.insertBefore(js,fjs);
                }
            }(document,"script","twitter-wjs");
          </script>
          }))

(define/doc (twitter-timeline
             [user string?]
             [widget-id string?]
             [#:width width (or/c #f number?) #f]
             [#:height height (or/c #f number?) #f]
             [#:lang lang (or/c #f string?) #f]
             [#:theme data-theme (or/c #f string?) #f]
             [#:link-color data-link-color (or/c #f string?) #f]
             [#:border-color data-border-color (or/c #f string?) #f]
             [#:tweet-limit data-tweet-limit (or/c #f string?) #f]
             [#:chrome data-chrome (or/c #f string?) #f]
             [#:aria-polite data-aria-polite (or/c #f string?) #f]
             [#:related data-related (or/c #f string?) #f]
             list?)
  @{See @url["https://dev.twitter.com/docs/embedded-timelines"]
    for instructions how to create a timeline and get its
    ``widget ID''.}
  ;; Reduce the tedium of translating optional arguments into HTML
  ;; attributes, where #f means no values at all.
  (define-syntax (and/attrs stx)
    (syntax-case stx ()
      [(_ id ...)
       #'(string-join (filter identity
                              (list (and id
                                         (format "~a=\"~a\"" 'id id)) ...)))]))
  (define attrs (and/attrs width
                           height
                           lang
                           data-theme
                           data-link-color
                           data-border-color
                           data-tweet-limit
                           data-chrome
                           data-aria-polite
                           data-related))
  @list{<a class="twitter-timeline" href="https://twitter.com/@|user|"
           data-widget-id="@|widget-id|"
           @|attrs|>
        </a>
        <script>
          !function(d,s,id){
              var js,fjs=d.getElementsByTagName(s)[0];
              if(!d.getElementById(id)){
                  js=d.createElement(s);
                  js.id=id;
                  js.src="//platform.twitter.com/widgets.js";
                  fjs.parentNode.insertBefore(js,fjs);
              }
          }(document,"script","twitter-wjs");
        </script>
        })

(define/doc (twitter-share-button [uri string?] list?)
  @{Typically used in a @secref["post-template"].}
  @list{
        <script type="text/javascript">
          !function(d,s,id){
              var js,fjs=d.getElementsByTagName(s)[0];
              if(!d.getElementById(id)){
                  js=d.createElement(s);
                  js.id=id;
                  js.src="//platform.twitter.com/widgets.js";
                  fjs.parentNode.insertBefore(js,fjs);
              }
          }(document,"script","twitter-wjs");
        </script>
        <a href="https://twitter.com/share"
           class="twitter-share-button"
           data-url="@uri"
           data-dnt="true">
          "Tweet"</a>
          })

(provide gittip-receiving)
(define (gittip-receiving username)
  @list{
        <script data-gittip-username="@|username|" src="//gttp.co/v1.js">
        })

(provide gittip-button)
(define (gittip-button username)
  @list{
        <script data-gittip-username="@|username|"
        data-gittip-widget="button" src="//gttp.co/v1.js"></script>
        })

(define/doc (gist [username string?]
                  [id string?]
                  list?)
  @{Include a @hyperlink["https://gist.github.com/"]{gist.}}
  @list{
        <script src="//gist.github.com/@|username|/@|id|.js"></script>
       })

(define/doc (math-jax list?)
  @{@itemlist[#:style 'ordered
              @item{Use this in the @tt{<head>} of your @secref["page-template"].}
              @item{In your markdown source files, use @litchar{\\( some math \\)}
                    for inline and @litchar{\\[ some math \\]} for display. Note
                    the @italic{double} backslashes, @litchar{\\}, because in
                    markdown @litchar{\} already has a meaning.}]}
  @list{
        <script type="text/javascript" async
                src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
        </script>
       })
