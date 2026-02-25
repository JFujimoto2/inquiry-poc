module Admin
  class EmailTemplatesController < BaseController
    before_action :set_email_template, only: %i[show edit update destroy preview]

    TEMPLATE_VARIABLES = %w[
      facility_name company_name contact_name
      desired_date num_people total_amount
    ].freeze

    def index
      @email_templates = EmailTemplate.includes(:facility).order("facilities.name")
    end

    def show; end

    def new
      @email_template = EmailTemplate.new
    end

    def create
      @email_template = EmailTemplate.new(email_template_params)
      if @email_template.save
        redirect_to admin_email_template_path(@email_template), notice: "Email template was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @email_template.update(email_template_params)
        redirect_to admin_email_template_path(@email_template), notice: "Email template was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @email_template.destroy!
      redirect_to admin_email_templates_path, notice: "Email template was successfully deleted.", status: :see_other
    end

    def preview
      sample_data = {
        "facility_name" => @email_template.facility.name,
        "company_name" => "Sample Company",
        "contact_name" => "Sample Contact",
        "desired_date" => Date.current.to_s,
        "num_people" => "10",
        "total_amount" => "150,000"
      }
      @preview_subject = interpolate(@email_template.subject, sample_data)
      @preview_body = interpolate(@email_template.body, sample_data)
    end

    private

    def set_email_template
      @email_template = EmailTemplate.find(params[:id])
    end

    def email_template_params
      params.require(:email_template).permit(:facility_id, :subject, :body)
    end

    def interpolate(text, data)
      text.gsub(/\{\{(\w+)\}\}/) { |_| data[$1] || "{{#{$1}}}" }
    end
  end
end
