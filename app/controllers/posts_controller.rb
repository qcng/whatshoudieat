class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize, except: [:show, :index]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end
  
  def list
    @posts = Post.all
    if params[:search]
      @posts = Post.search(params[:search]).order("created_at DESC")
    else
      @posts = Post.all.order("created_at DESC")
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @comments = Comment.where(post_id: @post).order("created_at DESC")
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def update
  
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def create
    @post = current_user.posts.build(post_params)
    respond_to do |format|
      if !verify_recaptcha(model: @post) || !@post.save
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      else
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      end

    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :content, :image)
    end
    
    def authorize
      if current_user.nil?
        redirect_to login_url, alert: "Not authorize! Please log in."
      else
        if @post && @post.user != current_user
          redirect_to root_path, alert: "Not authorize! Only #{@post.user.name} has access to this post. "
        end
      end
    end
      
end
