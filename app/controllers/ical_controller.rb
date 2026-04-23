# frozen_string_literal: true

class IcalController < WebController
  def show
    authorize!(:show, canteen)

    respond_to do |format|
      format.ics do
        calendar = Icalendar::Calendar.new
        calendar.url = ical_url(canteen, slug: canteen.slug)
        calendar.prodid = "openmensa.org"
        calendar.publish

        days.each do |day|
          calendar.events << day.decorate.as_ics_event
        end

        send_data calendar.to_ical,
          type: "text/calendar; charset=utf-8",
          disposition: "attachment; filename=\"#{canteen.name.parameterize}.ics\""
      end
    end
  end

  private

  def canteen
    @canteen ||= begin
      canteen = Canteen.find(params[:id])
      canteen = canteen.replaced_by if canteen.replaced?
      canteen
    end
  end

  def days
    @days ||= canteen.days
      .strict_loading
      .includes(meals: :notes)
      .where(days: {date: Time.zone.today...(Time.zone.today + 7.days)})
  end
end
