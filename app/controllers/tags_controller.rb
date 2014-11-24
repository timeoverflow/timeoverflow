class TagsController < ApplicationController
  respond_to :json, :html, :js

  def index
    @posts = Post.by_organization(current_organization).actives
    @all_tags = @posts.find_like_tag(params[:term])
    respond_with @all_tags
  end

  def alpha_grouped_index
    permitted = tags_params(params)

    post_type = permitted[:post_type] || "offer"

    @offers_tagged = []
    @inquiries_tagged = []

    redirect_to users_path && return unless current_organization

    set_alpha_tags(post_type)
    set_current_post_type(post_type)

    respond_with @alpha_tags
  end

  def inquiries
    @current_post_type = "inquiries"

    @alpha_tags = Inquiry.by_organization(current_organization).actives.
                  alphabetical_grouped_tags
    render partial: "grouped_index", locals: { alpha_tags: @alpha_tags }
  end

  def offers
    @current_post_type = "offers"
    @alpha_tags = Offer.by_organization(current_organization).actives.
                  alphabetical_grouped_tags
    render partial: "grouped_index", locals: { alpha_tags: @alpha_tags }
  end

  def posts_with
    permitted = tags_params(params)
    tagname = permitted[:tagname] || ""

    @offers_tagged = Offer.by_organization(current_organization).actives.
                     tagged_with(tagname)
    @inquiries_tagged = Inquiry.by_organization(current_organization).actives.
                        tagged_with(tagname)
    respond_with @offers_tagged, @inquiries_tagged
  end

  private

  def tags_params(params)
    params.permit(:post_type, :tagname)
  end

  def set_alpha_tags(post_type)
    @alpha_tags = case post_type
                  when "offer" then Offer
                  when "inquiry" then Inquiry
                  when "all" then Post
                  end.by_organization(current_organization).
                  actives.
                  alphabetical_grouped_tags
  end

  def set_current_post_type(post_type)
    @current_post_type = case post_type
                         when "offer" then "offers"
                         when "inquiry" then "inquiries"
                         when "all" then "all"
                         end
  end
end
