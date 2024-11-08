class LineItemsController < ApplicationController
  include CurrentCart
  before_action :set_cart, only: %i[ create destroy ]
  before_action :set_line_item, only: %i[ show edit update destroy ]

  # GET /line_items or /line_items.json
  def index
    @line_items = LineItem.all
  end

  # GET /line_items/1 or /line_items/1.json
  def show
  end

  # GET /line_items/new
  def new
    @line_item = LineItem.new
  end

  # GET /line_items/1/edit
  def edit
  end

  # POST /line_items or /line_items.json
  def create
    product = Product.find(params[:product_id])
    @line_item = @cart.add_product(product)

    respond_to do |format|
      if @line_item.save
        format.turbo_stream { @current_item = @line_item }
        format.html { redirect_to store_index_url }
        format.json { render :show, status: :created, location: @line_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /line_items/1 or /line_items/1.json
  def update
    quantity = params[:quantity].to_i

    if quantity > 10
      @line_item.errors.add(:quantity, "cannot exceed 10")
    elsif quantity <= 0
      @line_item.destroy
    else
      @line_item.update(quantity: quantity)
    end

    if @line_item.errors.empty?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            :cart,
            partial: 'layouts/cart',
            locals: { cart: @line_item.cart }
          )
        end
        format.html { redirect_to store_index_url, status: :see_other }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /line_items/1 or /line_items/1.json
  def destroy
    @line_item.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          :cart,
          partial: 'layouts/cart',
          locals: { cart: @cart }
        )
      end
      format.html { redirect_to store_index_url, status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line_item
      @line_item = LineItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def line_item_params
      params.require(:line_item).permit(:product_id)
    end
end
