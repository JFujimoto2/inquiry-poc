module Admin
  class CalendarTypesController < BaseController
    before_action :set_calendar_type, only: %i[edit update destroy]

    def index
      @calendar_types = CalendarType.order(:date)
    end

    def new
      @calendar_type = CalendarType.new
    end

    def create
      @calendar_type = CalendarType.new(calendar_type_params)
      if @calendar_type.save
        redirect_to admin_calendar_types_path, notice: "Calendar type was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @calendar_type.update(calendar_type_params)
        redirect_to admin_calendar_types_path, notice: "Calendar type was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @calendar_type.destroy!
      redirect_to admin_calendar_types_path, notice: "Calendar type was successfully deleted.", status: :see_other
    end

    def bulk_create
      dates = parse_date_range(params[:start_date], params[:end_date])
      day_type = params[:day_type]

      created_count = 0
      dates.each do |date|
        ct = CalendarType.find_or_initialize_by(date: date)
        ct.day_type = day_type
        created_count += 1 if ct.save
      end

      redirect_to admin_calendar_types_path,
        notice: "#{created_count} calendar type(s) created/updated."
    end

    private

    def set_calendar_type
      @calendar_type = CalendarType.find(params[:id])
    end

    def calendar_type_params
      params.require(:calendar_type).permit(:date, :day_type)
    end

    def parse_date_range(start_date, end_date)
      (Date.parse(start_date)..Date.parse(end_date)).to_a
    end
  end
end
