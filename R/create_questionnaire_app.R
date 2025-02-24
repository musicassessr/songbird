
# create_questionnaire_app(type = "kids", pre_post = "pre")
# create_questionnaire_app(type = "parents", pre_post = "pre")
# create_questionnaire_app(type = "teachers", pre_post = "pre")

create_questionnaire_app <- function(force_p_id_from_url = FALSE,
                                     type = c("kids", "parents", "teachers"),
                                     pre_post = c("pre", "post")) {

  type <- match.arg(type)
  pre_post <- match.arg(pre_post)

  stopifnot(
    type %in% c("kids", "parents", "teachers"),
    pre_post %in% c("pre", "post")
  )

  if(pre_post == "pre") {

    if(type == "kids") {
      tl <- kids_tl_pretest
    }
    if(type == "parents") {
      tl <- parents_tl_pretest
    }
    if(type == "teachers") {
      tl <- teachers_tl_pretest
    }

  } else {
    # post test TLs...
  }

  make_test(
    opt = test_options(
      title = "SingPause",
      admin_password = "ilikecheesepie432",
      researcher_email = "sebsilas@gmail.com",
      allow_any_p_id_url = TRUE,
      force_p_id_from_url = force_p_id_from_url
    ),

    elts = join(tl,
                final_page("Dankeschön!")
                )

  )
}
