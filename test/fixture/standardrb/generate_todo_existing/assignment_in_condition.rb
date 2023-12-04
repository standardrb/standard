class ErrorsOne
  def stuff(id)
    if bar = Bar.find(id)
      bar.nice!
    else
      false
    end
  end
end
