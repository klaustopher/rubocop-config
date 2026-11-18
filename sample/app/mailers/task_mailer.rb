class TaskMailer < ApplicationMailer
  before_action { @recipient = params[:recipient] }

  def assigned
    @task = params[:task]

    I18n.with_locale(@recipient.locale) do
      mail(
        to:      email_address_with_name(@recipient.email, @recipient.name),
        subject: t(".subject", reference: @task.reference, title: @task.title.truncate(60))
      )
    end
  end

  def overdue_digest
    @tasks = params[:tasks]

    I18n.with_locale(@recipient.locale) do
      mail(
        to:      email_address_with_name(@recipient.email, @recipient.name),
        subject: t(".subject", count: @tasks.size)
      )
    end
  end
end
