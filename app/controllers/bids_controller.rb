# frozen_string_literal: true

class BidsController < ApplicationController
  before_action :check_modifiable, only: %i[edit update]
  before_action :set_bid, only: %i[show destroy files_upload]
  before_action :check_project_owner, only: %i[accept reject]

  def index
    @bids = if admin?
              Bid.all_bids
            elsif freelancer?
              current_user.bids
            else
              return redirect_to_root_with_err('You cannot view this page')
            end
    @bids = @bids.page params[:page]
  end

  def show
    @bids_related_to_user = admin? ? Bid.all_bids : Bid.to_freelancer_or_awardee_client(current_user)
  end

  def new
    return redirect_to_root_with_err('Bid cannot be created') unless freelancer?

    @project = Project.find_by(id: params[:project_id])
    @bid = Bid.new
  end

  def edit; end

  def create
    @project = Project.find_by(id: params['bid']['project_id'])
    @bid = Bid.new(bid_params)

    if @bid.save
      redirect_to @bid.project, flash: { success: 'Bid was successfully created' }
    else
      flash.now[:error] = 'Bid could not be created.'
      render 'new', locals: { project: @project }
    end
  end

  def update
    if @bid&.update(bid_params)
      redirect_to @bid, flash: { success: 'Bid was successfully updated' }
    else
      flash.now[:error] = 'Please enter the information correctly'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bid.destroy
    redirect_to bids_path, flash: { notice: 'Bid was successfully deleted' }
  end

  def accept
    @bid.accept
    redirect_to @bid.project, flash: { notice: 'Bid accepted' }
  end

  def reject
    @bid.reject
    redirect_to @bid.project, flash: { notice: 'Bid rejected' }
  end

  def files_upload
    unless files_present?
      flash.now[:error] = 'Please upload at least one file'
      return render :edit, status: :unprocessable_entity
    end

    attach_files
    check_validity_of_files(@bid)
  end

  private

  def attach_files
    bid = params[:bid]
    @bid.bid_code_document.attach(bid[:bid_code_document])
    @bid.bid_design_document.attach(bid[:bid_design_document])
    @bid.bid_other_document.attach(bid[:bid_other_document])

    return unless @bid.valid?

    @bid.upload_project_files
  end

  def check_validity_of_files(bid)
    if bid.valid?
      redirect_to bid, flash: { success: 'Files uploaded successfully' }
    else
      flash.now[:error] = 'The files must be PDFs and less than 25MB'
      render :edit, status: :unprocessable_entity
    end
  end

  def check_modifiable
    @bid = Bid.editable_by(current_user).find_by(id: params[:id])
    redirect_to bids_path, flash: { error: 'Bid cannot be modified' } if @bid.nil? || @bid.rejected?
  end

  def files_present?
    bid = params[:bid]
    return false if bid.nil?

    [bid[:bid_code_document], bid[:bid_design_document], bid[:bid_other_document]]
      .count(&:present?).positive?
  end

  def check_project_owner
    @bid = Bid.owned_by(current_user).find_by(id: params[:id])
    redirect_to_root_with_err('You are not authorized to perform this action') if @bid.nil?
  end

  def set_bid
    @bid = Bid.find_by(id: params[:id])
    redirect_to bids_path, flash: { error: 'Bid not found' } if @bid.nil?
  end

  def bid_params
    params.require(:bid).permit(:bid_description, :bid_amount, :project_id, :user_id, :bid_code_document,
                                :bid_design_document, :bid_other_document)
  end
end
