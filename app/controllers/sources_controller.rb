# frozen_string_literal: true

class SourcesController < WebController
  load_and_authorize_resource :parser
  load_and_authorize_resource :source, through: :parser, shallow: true

  def new
    @canteen = Canteen.new
    @source.canteen = @canteen
  end

  def edit
    @new_feed = @source.feeds.new
  end

  def create
    if params.dig(:source, :canteen_id).present?
      create_with_existing_canteen
    else
      create_with_new_canteen
    end
  end

  def update
    flash[:notice] = if @source.update source_params
                       t "message.source_saved"
                     else
                       t "message.source_invalid"
                     end

    redirect_to parser_path(@source.parser)
  end

  def sync
    @synchroniser = OpenMensa::SourceUpdater.new @source
    @synchroniser.sync
  end

  def messages
    @messages = @source.messages.order(created_at: :desc)
  end

  private

  def create_with_existing_canteen
    @source.validate

    canteen = Canteen.orphaned.find_by(id: params.dig(:source, :canteen_id))
    unless canteen
      @source.errors.add :canteen, :invalid
      render :new
      return
    end

    ActiveRecord::Base.transaction do
      @source.update!(canteen_id: canteen.id)

      flash[:notice] = t "message.source_created"
      redirect_to parser_path(@source.parser)
    end
  rescue ActiveRecord::RecordInvalid
    render :new
  end

  def create_with_new_canteen
    @canteen = Canteen.new(canteen_params)
    @source.canteen = @canteen

    ActiveRecord::Base.transaction do
      @canteen.validate
      @source.validate

      @canteen.save!
      @source.save!

      flash[:notice] = t "message.source_created"
      redirect_to parser_path(@source.parser)
    end
  rescue ActiveRecord::RecordInvalid
    render :new
  end

  def source_params
    params.require(:source).permit(:name, :meta_url, :parser_id, :canteen_id)
  end

  def canteen_params
    params.require(:canteen).permit(:address, :name, :latitude, :longitude, :city, :phone, :email)
  end
end
